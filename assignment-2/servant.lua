local luarpc = require("luarpc")

local obj = {
    foo = function(left, message, right)
        return left + right, message .. " is working"    
    end,
    bar = function(number)
        return number + 10
    end,
    character = function(c)
        local number = tonumber(c)
        if not number then return 0, 1 end
        local c1 = string.format("%d", tostring(number) + 1)
        local c2 = string.format("%d", tostring(number) + 2)
        return c1, c2
    end
}

-- catalogue
local ip, port = "0.0.0.0", assert(arg[1])
local catalogue = luarpc.createProxy(ip, port, "catalogue.interface")

function create_register_servant(interface_file, name)
    local ip, port = luarpc.createServant(obj, interface_file)
    local err = catalogue.register(ip, port, name)
    assert(not err, err)
end

create_register_servant("interface.interface", "someinterface1")
create_register_servant("interface.interface", "someinterface2")

luarpc.waitIncoming()
