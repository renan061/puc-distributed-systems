local luarpc = require("luarpc")

local proxy = luarpc.createProxy("0.0.0.0", 8080, "interface")

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

-- another function
local err, number = proxy.bar(15)
assert(number == 25)

-- implict convertion from string to number
local err, number = proxy.bar("2.5")
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

-- unknown function
-- TODO: not working
local err, value = proxy.baz(1, "string", 2)
assert(err == "", err)
assert(not value)
