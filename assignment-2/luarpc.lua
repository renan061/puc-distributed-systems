local idl = require("idl")
local protocol = require("protocol")
local socket = require("socket")

local ERROR_LUARPC = "luarpc error: "

local ERROR_CLOSED = "socket closed"
local ERROR_TIMEOUT = "request timeout"
local ERROR_UNIMPLEMENTED_FUNCTION = "servant does not implement function"
local ERROR_UNKNOWN_FUNCTION = "not and interface function"

local luarpc = {}

-----------------------------------------------------
--
--  Stub Metatable
--
-----------------------------------------------------

local stubmt = {
    -- treats calls to functions that are not in the idl
    __index = function(_, key)
        local function_name = string.format(" '%s'", key)
        return function()
            return luarpc_error(ERROR_UNKNOWN_FUNCTION) .. function_name
        end
    end
}

-----------------------------------------------------
--
--  Auxiliary
--
-----------------------------------------------------

function luarpc_error(error)
    return ERROR_LUARPC .. error
end

function receive(client, pattern)
    local string, err = client:receive(pattern)
    if err then
        if err == "closed" then
            return nil, ERROR_CLOSED
        elseif err == "timeout" then
            return nil, ERROR_TIMEOUT
        else
            error("internal error: " .. err)
        end
    end
    return string
end

-----------------------------------------------------
--
--  createProxy
--
-----------------------------------------------------

function luarpc.createProxy(ip, port, idl_file)
    local stub = {}
    setmetatable(stub, stubmt)

    local idl = idl.new(idl_file)

    for name, method in pairs(idl) do
        stub[name] = function(...)
            local arguments = {...}

            -- removes extra arguments
            for i = #arguments, #method.parameter_types + 1, -1 do
                table.remove(arguments, i)
            end

            -- checks arguments' types
            for i, argument in ipairs(arguments) do
                local parameter_type = method.parameter_types[i]
                local _, err = idl.convert_value(argument, parameter_type)
                if err then return luarpc_error(err) end
            end

            -- adds missing arguments with zero values
            for i = #arguments + 1, #method.parameter_types do
                local parameter_type = method.parameter_types[i]
                if parameter_type == idl.type.double then
                    table.insert(arguments, 0.0)
                elseif parameter_type == idl.type.string then
                    table.insert(arguments, "")
                elseif parameter_type == idl.type.char then
                    table.insert(arguments, "")
                else
                    error("internal error: invalid interface type")
                end
            end

            -- tries to connect to the servant
            local client, err = socket.connect(ip, port)
            if err then
                return luarpc_error("could not connect to servant")
            end

            -- calls the servant remotely
            local string = protocol.marshall({name, table.unpack(arguments)})
            client:send(string)
            local string, err = receive(client, "*a")
            client:close()
            if err then return err end
            
            -- unmarshalls the response and checks for possible errors
            local return_values = protocol.unmarshall(string)
            if return_values[1] == protocol.error then
                return luarpc_error(return_values[2])
            end

            -- converts the returned values to match the interface's types
            for i, return_value in ipairs(return_values) do
                local return_type = method.return_types[i]
                local value, err = idl.convert_value(return_value, return_type)
                if err then return luarpc_error(err) end
                return_values[i] = value
            end

            return nil, table.unpack(return_values)
        end
    end

    return stub
end

-----------------------------------------------------
--
--  createServant
--
-----------------------------------------------------

local servants = {}

function luarpc.createServant(object, idl_file) -- returns ip, port
    local socket = assert(socket.bind("*", 0)) -- ASK: always localhost?
    local ip, port = socket:getsockname() -- ASK: settimeout?

    table.insert(servants, {
        socket = socket,
        idl = idl.new(idl_file),
        object = object
    })

    return ip, port
end

-----------------------------------------------------
--
--  waitIncoming
--
-----------------------------------------------------

-- auxiliary
function servant_receive(client, idl) -- returns function_name, arguments, err
    -- receives the function's name
    local function_name, err = receive(client, "*l")
    if err then
        return nil, nil, err
    end

    -- checks if the function exists in the idl
    local idl_function = idl[function_name] 
    if not idl_function then
        return nil, nil, ERROR_UNKNOWN_FUNCTION
    end

    -- receives the arguments
    local arguments = {}
    for _, parameter_type in ipairs(idl_function.parameter_types) do
        local value, err = receive(client, "*l")
        if err then return nil, nil, err end

        local argument, err = idl.convert_value(value, parameter_type)
        if err then return nil, nil, err end

        table.insert(arguments, argument)
    end

    return function_name, arguments
end

function luarpc.waitIncoming()
    if #servants < 1 then return end

    -- fills a list with the sockets from the servants
    local sockets = {}
    for _, servant in ipairs(servants) do
        table.insert(sockets, servant.socket)
    end

    while true do
        local sockets, _, err = socket.select(sockets, nil)
        assert(not err) -- ASK: should be an assertion?

        for i, socket in ipairs(sockets) do
            -- finds the corresponding servant for the socket
            local servant
            for _, s in ipairs(servants) do
                if s.socket == socket then
                    servant = s
                    break
                end
            end

            -- accepts the connection
            local client, err = socket:accept()
            if err then
                print("internal error: " .. err)
                goto continue
            end

            -- receives the marshalled message and unmarshalls it
            local idl = servant.idl
            local function_name, arguments, err = servant_receive(client, idl)
            if err then
                client:send(protocol.marshall_error(err))
                client:close()
                goto continue
            end

            -- checks if the associated function exists
            local function_ = servant.object[function_name]
            if not function_ then
                function_name = string.format(" '%s'", function_name)
                local message = ERROR_UNIMPLEMENTED_FUNCTION .. function_name
                client:send(protocol.marshall_error(message))
                client:close()
                goto continue
            end

            -- calls the function and sends the return values back
            client:send(protocol.marshall({function_(table.unpack(arguments))}))
            client:close()

            ::continue::
        end
    end
end

-----------------------------------------------------
--
--  Module
--
-----------------------------------------------------

return luarpc
