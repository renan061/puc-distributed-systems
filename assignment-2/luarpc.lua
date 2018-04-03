local idl = require("idl")
local protocol = require("protocol")
local socket = require("socket")

local ERROR_TIMEOUT = "todo: error timeout"
local ERROR_UNKNOWN = "todo: error unknown"
local ERROR_RPC = "rpc error: "

local luarpc = {}

-----------------------------------------------------
--
--  createProxy
--
-----------------------------------------------------

-- auxiliary
local function remote_call(ip, port, message) -- TODO: asserts
    local client, err = socket.connect(ip, port)
    if err then
        print(ERROR_RPC .. "could not connect to servant")
        return nil
    end

    client:send(message)
    local responses = {}

    while true do
        local response, err = client:receive()
        if response == nil then
            if err == "closed" then break
            elseif err == "timeout" then print(ERROR_TIMEOUT); return nil
            else print(ERROR_UNKNOWN); return nil end
        end
        table.insert(responses, response)
    end

    client:close()

    if responses[1] == protocol.ERROR then
        assert(#responses == 2)
        print(ERROR_RPC .. responses[2])
        return nil
    end

    return responses
end

function luarpc.createProxy(ip, port, interface_file)
    local interface_object = idl.parse(interface_file)
    assert(interface_object.name) -- does nothing with the interface name
    return idl.convert(interface_object, function(func, args, rets)
        local message = protocol.parse(func, args)
        local responses = remote_call(ip, port, message)
        if not responses then return nil end
        for i, response in ipairs(responses) do
            -- TODO: move to idl
            if rets[i] == "double" then
                local number = tonumber(response)
                if not number then
                    print("todo err: returned value " .. i .. " must be a " .. rets[i])
                    return nil
                end
                responses[i] = number
            elseif rets[i] == "string" then
                local string = tostring(response)
                if not string then
                    print("todo err: returned value " .. i .. " must be a " .. rets[i])
                    return nil
                end
                responses[i] = string
            else
                assert(nil) -- TODO
            end
        end
        return table.unpack(responses)
    end)
end

-----------------------------------------------------
--
--  createServant
--
-----------------------------------------------------

local servants = {}

function luarpc.createServant(object, interface_file) -- returns ip, port
    local socket, ip, port = sockets.server()
    table.insert(servants, {socket = socket, object = object})
    return ip, port
end

-----------------------------------------------------
--
--  waitIncoming
--
-----------------------------------------------------

function luarpc.waitIncoming()
    if #servants < 1 then return end -- ASK

    -- select
    local servantSockets = {}
    for _, s in ipairs(servants) do
        s:settimeout(1) -- ASK
        table.insert(servantSockets, s)
    end
    local ready = sockets.wait(servantSockets)

    -- getting the ready servant
    for i, s in ipairs(servants) do
        if ready == s then
            ready = servants[i]
            break
        end
    end

    -- running the servant
    local payload, err = ready.socket:receive()
    assert(not err, err) -- ASK
    

    
end

-----------------------------------------------------
--
--  Module
--
-----------------------------------------------------

return luarpc
