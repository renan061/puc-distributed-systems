local socket = require("socket")
local host, port = arg[2] or "localhost", arg[3] or 8080
local iterations, repetitions = 10, 10000

-- auxiliary
function divider() for i = 1, 50 do io.write("-") end io.write("\n") end

-- auxiliary
function getfrom(client)
    client:send("catchphrase\n")
    return assert(client:receive())
end

-- keeps the socket
function client1()
    local t = socket.gettime()
    local c = assert(socket.connect(host, port))
    for _ = 1, repetitions do getfrom(c) end
    c:close()
    return socket.gettime() - t
end

-- closes the socket
function client2()
    local t = socket.gettime()
    for _ = 1, repetitions do
        local c = assert(socket.connect(host, port))
        getfrom(c)
        c:close()
    end
    return socket.gettime() - t
end

-- tests
function test(f)
    local times, total = {}, 0
    for i = 1, iterations do
        local time = f()
        table.insert(times, time)
        total = total + time
    end
    io.write("Times: \n")
    for _, value in ipairs(times) do
        io.write("-- " .. tostring(value) .. "\n")
    end
    io.write("Iterations: " .. iterations .. " * " .. repetitions .. "\n")
    io.write("Total time: " .. total .. "\n")
    local average = total / iterations
    io.write("Average time: " .. average .. "\n")

    return times, total, average
end

divider()
local _, t1, _ = test(client1)
divider()
local _, t2, _ = test(client2)
divider()
io.write("Client 1 was " .. (t2 / t1) .. " times faster than Client 2\n")
