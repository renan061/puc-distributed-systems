local socket = require("socket")
local message = require("message")
local host, port = arg[1] or "*", arg[2] or 8080

local s = assert(socket.bind(host, port))
local ip, port = s:getsockname()
assert(ip, port)

while true do
    local c = assert(s:accept())
    while true do
        local payload, err = c:receive()
        if err then break end
        c:send(message)
    end
    c:close()
end
