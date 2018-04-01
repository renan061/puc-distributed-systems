local sockets = require("sockets")

-- TODO: remove
local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local luarpc = {}

-----------------------------------------------------
--
--  Auxiliary
--
-----------------------------------------------------

-- validates a interface type
local function validatetype(t, canvoid)
    if t == "void" then assert(canvoid, "invalid type void for parameter")
    else assert(t == "double" or t == "string", "invalid type " .. t) end
end

-----------------------------------------------------
--
--  createProxy
--
-----------------------------------------------------

function luarpc.createProxy(ip, port, interface_file)
    -- "parsing" from interface file
    local obj
    function interface(t) obj = t end
    dofile(interface_file)

    -- does nothing with the interface name
    assert(obj.name)

    -- fills the proxy with methods from the interface
    local proxy = {}
    for method_name, method_data in pairs(assert(obj.methods)) do
        -- return type
        validatetype(method_data.resulttype, true)
        local returns = {} -- stores all return values' types
        if method_data.resulttype ~= "void" then
            table.insert(returns, method_data.resulttype)
        end

        -- parameters
        local parameters = {} -- stores all parameters' types
        for _, param in pairs(assert(method_data.args)) do
            local dir = assert(param.direction)
            validatetype(assert(param.type), false)

            if dir == "in" then
                table.insert(parameters, param.type)
            elseif dir == "out" then
                table.insert(returns, param.type)
            elseif dir == "inout" then
                table.insert(parameters, param.type)
                table.insert(returns, param.type)
            else
                assert(nil, "invalid parameter type - " .. param.type)
            end
        end
        
        -- defines the method in the proxy
        proxy[method_name] = function(...)
            local args = {}
            for _, arg in ipairs{...} do table.insert(args, arg) end

            assert(#parameters >= #args, "too many arguments") -- ASK

            -- ASK: convert "2" to 2.0?
            -- checks the provided arguments
            for i = 1, #args do
                local p, a = parameters[i], type(args[i])
                if a == "number" and p ~= "double" or
                   a == "string" and p ~= "string" then
                    assert(nil, "got '" .. a .. "' and expected '" .. p .. "'")
                end
            end

            -- gives zero values based on type for missing arguments
            for i = #args + 1, #parameters do
                local tp = parameters[i]
                if tp == "double" then
                    table.insert(args, 0.0)
                elseif tp == "string" then
                    table.insert(args, "")
                end
            end

            -- TODO: call remote
            print("nugget")
            
            -- TODO: do something with returns
            -- print(returns)
        end
    end

    return proxy
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
