local luarpc = require("luarpc")

-- catalogue
local ip, port = "0.0.0.0", assert(arg[1])
local catalogue = luarpc.createProxy(ip, port, "catalogue_interface")

-- someinterface1
local rpcerr, ip, port, err = catalogue.get("someinterface1")
assert(not rpcerr, rpcerr)
assert(not err, err)
local proxy = luarpc.createProxy(ip, port, "interface")

-- ok
local err, number, string = proxy.foo(17.3, "foo", 2.7)
assert(not err, err)
assert(number == 20, string.format("%.1f != 20", number))
assert(string == "foo is working", string)

-- extra arguments
local err, number, string = proxy.foo(17.3, "foo", 2.7, "extra1", "extra2")
assert(not err, err)
assert(number == 20, string.format("%.1f != 20", number))
assert(string == "foo is working", string)

-- extra return values
local err, number, string, extra1, extra2 = proxy.foo(17.3, "foo", 2.7)
assert(not err, err)
assert(number == 20, string.format("%.1f != 20", number))
assert(string == "foo is working", string)
assert(not extra1)
assert(not extra2)

-- another function ok
local err, number = proxy.bar(15)
assert(not err)
assert(number == 25)

-- implict convertion from string to number
local err, number = proxy.bar("2.5")
assert(not err)
assert(number == 12.5)

-- implict convertion from number to string
local err, number, string = proxy.foo(17.3, "number", 2.7)
assert(not err, err)
assert(number == 20, string.format("%.1f != 20", number))
assert(string == "number is working", string)

-- implict convertion from number to string and string to number
local err, number, string = proxy.foo(17.3, "number", "2.7")
assert(not err, err)
assert(number == 20, string.format("%.1f != 20", number))
assert(string == "number is working", string)

-- unimplemented function
local err, value = proxy.baz(1, "string", 2)
assert(err == "luarpc error: servant does not implement function 'baz'", err)
assert(not value)

-- unknown function
local err, value = proxy.bam()
assert(err == "luarpc error: not and interface function 'bam'", err)
assert(not value)

-- invalid parameter type
local err, value = proxy.bar("somestring")
assert(err == "luarpc error: can't convert 'somestring' to double", err)
assert(not value)
