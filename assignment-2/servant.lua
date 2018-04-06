local luarpc = require("luarpc")

local obj = {
    foo = function(left, message, right)
        return left + right, message .. " is working"
    end,
    bar = function(number)
        return number + 10
    end
}

-- catalogue
local ip, port = "0.0.0.0", assert(arg[1])
local catalogue = luarpc.createProxy(ip, port, "catalogue_interface")

-- someinterface1
local ip, port = luarpc.createServant(obj, "interface")
local err = catalogue.register(ip, port, "someinterface1")
assert(not err, err)

-- someinterface2
local ip, port = luarpc.createServant(obj, "interface")
local err = catalogue.register(ip, port, "someinterface2")
assert(not err, err)

luarpc.waitIncoming()
