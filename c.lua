local socket = require("socket")
local host, port = arg[1] or "localhost", arg[2] or 8080

print("Attempting connection to '" .. host .. "' on port " .. port .. "...")
c = assert(socket.connect(host, port))
print("Connected!")

function getfrom(client)
    client:send("catchphrase\n")
    return assert(client:receive())
end

print(getfrom(c))
print(getfrom(c))

c:close()
