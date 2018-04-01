local luarpc = require("luarpc")

local obj = {
    foo = function(a, b, s)
        return a - b, "tchau"
    end,
    boo = function(n)
            return 1
    end
}

local interface_file = "interface.lua"

local ip, port = luarpc.createServant(obj, interface_file)

print(ip, port)

-- local proxy = luarpc.createProxy("0.0.0.0", 8080, interface_file)
-- proxy.foo(1, "string", 2)
