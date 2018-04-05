local idl = require("idl")
local protocol = require("protocol")
local socket = require("socket")
local Interface = require("interface")

local ERROR_LUARPC = "luarpc error: "

local ERROR_CLOSED = ERROR_LUARPC .. "socket closed"
local ERROR_TIMEOUT = ERROR_LUARPC .. "request timeout"
local ERROR_UNKNOWN = ERROR_LUARPC .. "unknown"
local ERROR_UNKNOWN_FUNCTION = ERROR_LUARPC .. "unknown function"

local luarpc = {}

-----------------------------------------------------
--
--  Auxiliary
--
-----------------------------------------------------

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

-- TODO
function receive_arguments(client, interface_method)
    local arguments = {}

    for _, parameter_type in ipairs(interface_method.parameter_types) do
        local line, err = receive(client, "*l")
        if err then
            return nil, err
        end

        local argument, err = idl.convertvalue(line, parameter_type)
        if err then
            return nil, err
        end

        table.insert(arguments, argument)
    end

    return arguments
end

-- TODO
function receive_rpc(client, interface) -- returns function_name, arguments, err
    local function_name, err = receive(client, "*l")
    if err then
        return nil, nil, err
    end

    local interface_method = interface[function_name] 
    if not interface_method then
        return nil, nil, ERROR_UNKNOWN_FUNCTION
    end

    local arguments = receive_arguments(client, interface_method)
    if err then
        return nil, nil, err
    end

    return function_name, arguments
end

-----------------------------------------------------
--
--  createProxy
--
-----------------------------------------------------

function luarpc.createProxy(ip, port, interface_file)
    local stub, interface = {}, Interface.new(interface_file)

    for name, method in pairs(interface) do
        stub[name] = function(...)
            local arguments = {...}

            -- removes extra arguments
            for i = #arguments, #method.parameter_types + 1, -1 do
                table.remove(arguments, i)
            end

            -- checks arguments' types
            for i, argument in ipairs(arguments) do
                local parameter_type = method.parameter_types[i]
                local err = idl.compatible_type(argument, parameter_type)
                assert(not err, err)
            end

            -- adds missing arguments with zero values
            for i = #arguments + 1, #method.parameter_types do
                local parameter_type = method.parameter_types[i]
                if parameter_type == "double" then
                    table.insert(arguments, 0.0)
                elseif parameter_type == "string" then
                    table.insert(arguments, "")
                else
                    error("internal error: invalid interface type")
                end
            end

            -- tries to connect to the servant
            local client, err = socket.connect(ip, port)
            if err then
                return ERROR_LUARPC .. "could not connect to servant"
            end

            -- calls the servant remotely
            local string = protocol.marshall({name, table.unpack(arguments)})
            client:send(string)
            local string, err = receive(client, "*a")
            client:close()
            if err then
                return err
            end
            
            -- unmarshalls the response and checks for possible errors
            local return_values = protocol.unmarshall(string)
            if return_values[1] == protocol.ERROR then
                return ERROR_LUARPC .. return_values[2]
            end

            -- converts the returned values to match the interface's types
            for i, return_value in ipairs(return_values) do
                local return_type = method.return_types[i]
                return_values[i] = idl.convertvalue(return_value, return_type)
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

function luarpc.createServant(object, interface_file) -- returns ip, port
    -- low level
    function servantsocket()
        local host, port = "*", 8080 -- TODO: localhost, 8080
        local server = assert(socket.bind(host, port))
        local ip, port = server:getsockname()
        return server, ip, port
    end

    local socket, ip, port = servantsocket()

    table.insert(servants, {
        socket = socket,
        interface = Interface.new(interface_file),
        object = object
    })

    return ip, port
end

-----------------------------------------------------
--
--  waitIncoming
--
-----------------------------------------------------

function luarpc.waitIncoming()
    if #servants < 1 then return end -- ASK

    -- TODO
    local servant = servants[1]
    local server = servant.socket
    local interface = servant.interface
    local object = servant.object

    -- TODO: asserts and errors
    while true do
        local client = assert(server:accept())

        local function_name, arguments, err = receive_rpc(client, interface)
        if err then
            error(err)
        end

        local ret = {object[function_name](table.unpack(arguments))}

        client:send(protocol.marshall(ret))
        client:close()
    end
end

-- if #servants < 1 then return end -- ASK

-- -- select
-- local servantSockets = {}
-- for _, s in ipairs(servants) do
--     s:settimeout(1) -- ASK
--     table.insert(servantSockets, s)
-- end
-- local ready = sockets.wait(servantSockets)

-- -- getting the ready servant
-- for i, s in ipairs(servants) do
--     if ready == s then
--         ready = servants[i]
--         break
--     end
-- end

-- -- running the servant
-- local payload, err = ready.socket:receive()
-- assert(not err, err) -- ASK

-----------------------------------------------------
--
--  Module
--
-----------------------------------------------------

return luarpc
