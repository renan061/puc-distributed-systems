local socket = require("socket")
local message = require("message")
local host, port = arg[1] or "*", arg[2] or 8080

local close = true

print("Binding to host '" .. host .. "' and port " .. port .. "...")
local s = assert(socket.bind(host, port))
local ip, port = s:getsockname()
assert(ip, port)

while true do
    print("Ready on " .. ip .. ":" .. port .. "...")
    local c = assert(s:accept())

    repeat
        local payload, err1 = c:receive()
        local err2 = c:send(message)
    until err1 or err2 == nil or close

    print("Closed a client connection")
    c:close()
end
