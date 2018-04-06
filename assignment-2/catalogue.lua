local luarpc = require("luarpc")

local servants = {}

local catalogue = {
    register = function(ip, port, name)
        if servants[name] then
            return "error: catalogue name already in use"
        end

        servants[name] = {ip = ip, port = port}
        print(string.format("Registered %s at [%s %d]", name, ip, port))
        return nil
    end,
    get = function(name)
        local servant = servants[name]
        if not servant then
            return nil, nil, "error: catalogue has no servant named " .. name
        end

        print(string.format("Someone requested %s", name))
        return servant.ip, servant.port
    end
}

local ip, port = luarpc.createServant(catalogue, "catalogue_interface")
print(string.format("Catálogo - IP: %s, Porta: %s", ip, port))
luarpc.waitIncoming()
