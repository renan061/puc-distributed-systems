local luarpc = require("luarpc")

local obj = {
    foo = function(left, message, right)
        return left + right, message .. " is working"
    end,
    bar = function(number)
        return number + 10
    end
}

local ip, port = luarpc.createServant(obj, "interface")
print(string.format("IP: %s, Porta: %s", ip, port))
luarpc.waitIncoming()
