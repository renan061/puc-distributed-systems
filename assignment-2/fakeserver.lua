local socket = require("socket")
local message = arg[1] or "___ERRORPC: \nfakeserver default\n"
local host, port = "0.0.0.0", 8080

message = "string\nsomestring\n"

local s = assert(socket.bind(host, port))
local ip, port = s:getsockname()
assert(ip, port)

while true do
    local c = assert(s:accept())
    local payload, err = c:receive()
    if err then break end
    c:send(message)
    c:close()
end
