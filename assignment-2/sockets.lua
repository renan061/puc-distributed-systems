local socket = require("socket")

-- module
local sockets = {}

-- local variables
local host, port = "*", 0 -- localhost, any port

-- creates a new server socket
function sockets.server()
    local server = assert(socket.bind(host, port))
    local ip, port = server:getsockname()
    return server, ip, port
end

-- uses select to wait for requests
function sockets.wait(servers)
    -- accepting
    local clients = {}
    for _, server in ipairs(servers) do
        local client = server:accept()
        client:settimeout(0)
        client:setoption("tcp-nodelay", true)
        table.insert(clients, client)
    end

    local clst1, _, err = socket.select(clients, nil, 1)
    -- if not err ...
    for _, clt in ipairs(clst1) do
        local line, err = clt:receive("*l"))
        if line then
            clt:send(line)
        else
            print("ERRO: ".. err)
        end
    end
end

return sockets
