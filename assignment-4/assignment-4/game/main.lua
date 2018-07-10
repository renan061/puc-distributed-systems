local mqtt = require("mqtt_library")
local Player = require("player")
local Projectile = require("projectile")

dofile("configuration.lua")

math.randomseed(os.time())

joined = false
players = {}
projectiles = {}

-----------------------------------------------------
--
--  MQTT
--
-----------------------------------------------------

function mqttcb(topic, message)
    assert(loadstring(message))()
    print(topic .. ': ' .. m.name)
    if m.name == username then return end
    
    if topic == 'trabalho4/sd/keypressed' then
        players[m.name]:keypressed(m.keypressed)
    elseif topic == 'trabalho4/sd/keyreleased' then
        players[m.name]:keyreleased(m.keyreleased)
    elseif topic == 'trabalho4/sd/joined' then
        if players[m.name] == nil then
            -- create a copy of the player in my world
            players[m.name] = Player.new(m.name, m.x, m.y, m.r, m.g, m.b)
            -- send my info to new player
            mqtt_client:publish("trabalho4/sd/joined", player:join_info())
        end
    elseif topic == 'trabalho4/sd/unjoined' then
        p = players[m.name]
        p.x = -100; p.y = -100; p.r = 0; p.g = 0; p.b = 0
    end
end

username = arg[2] .. "-" .. tostring(math.random(99999))

mqtt_client = mqtt.client.create(arg[3], arg[4], mqttcb)
mqtt_client:connect(username)
mqtt_client:subscribe({
    "trabalho4/sd/keypressed",
    "trabalho4/sd/keyreleased",
    "trabalho4/sd/joined",
    "trabalho4/sd/unjoined"
})

-----------------------------------------------------
--
--  love2d
--
-----------------------------------------------------

function love.load(arg)
    -- if arg and arg[#arg] == "-debug" then require("mobdebug").start() end

    local w, h = love.graphics.getDimensions()
    local playerx
    local playery
    repeat
        playerx = math.random(10, w - 10)
        playery = math.random(10, h - 10)
    until not hitwall(playerx, playery, Player.size, Player.size)

    player = Player.new(
        username,
        playerx,
        playery,
        math.random(255),
        math.random(255),
        math.random(255)
    )

    if not joined then
        mqtt_client:publish("trabalho4/sd/joined", player:join_info())
        joined = true
    end

    players[username] = player
end

function love.update(dt)
    mqtt_client:handler()

    for _, player in pairs(players) do
        -- shots
        if player.shot then
            projectile = Projectile.new()
            projectiles[player.name .. ':' .. player.shots + 1] = projectile
            projectile.exists = true

            if player.direction == 'u' then
                projectile.x = player.x + player.size/2 - projectile.size/2
                projectile.y = player.y - (projectile.size + 1)
                projectile.speedy = -projectile.default_speed
            elseif player.direction == 'd' then
                projectile.x = player.x + player.size/2 - projectile.size/2
                projectile.y = player.y + player.size + projectile.size + 1
                projectile.speedy = projectile.default_speed
            elseif player.direction == 'l' then
                projectile.x = player.x - (projectile.size + 1)
                projectile.y = player.y + player.size/2 - projectile.size/2
                projectile.speedx = -projectile.default_speed
            elseif player.direction == 'r' then
                projectile.x = player.x + player.size + (projectile.size + 1)
                projectile.y = player.y + player.size/2 - projectile.size/2
                projectile.speedx = projectile.default_speed
            end

            player.shot = not player.shot
        end

        -- moves the projectiles
        for _, p in pairs(projectiles) do
            if p.exists then
                p.y = p.y + ((p.speedy) * dt)
                p.x = p.x + ((p.speedx) * dt)
                if hitwall(p.x, p.y, p.width, p.height) then
                    p.exists = false
                end
            end
        end

        -- moves the player
        local newx = player.x + (player.speedx * dt)
        local newy = player.y + (player.speedy * dt)
        if not hitwall(newx, newy, player.size, player.size) then
            if not hitplayer(player) then
                player.x = newx
                player.y = newy
            else
                -- gambiarra (to fix weird bug)
                local oldx = player.x
                local oldy = player.y
                player.x = newx
                player.y = newy
                if hitplayer(player) then
                    player.x = oldx
                    player.y = oldy
                end
            end
        end

        for _, player in pairs(players) do
            for _, projectile in pairs(projectiles) do
                local checkcollision = check_collision(
                    player.x,
                    player.y,
                    player.size,
                    player.size,
                    projectile.x,
                    projectile.y,
                    projectile.size,
                    projectile.size
                )
                if checkcollision then
                    player.life = player.life - 1
                    projectile.exists = false
                    if player.life == 0 then
                        t = {name = username}
                        print(serialize(t))
                        mqtt_client:publish(
                            "trabalho4/sd/unjoined",
                            serialize(t)
                        )
                        player.r = 0
                        player.g = 0
                        player.b = 0
                        player.x = -100
                        player.y = -100
                        -- player = nil
                        love.event.quit()
                    end
                end
            end
        end

        -- deletes non-existing projectiles
        for i, projectile in pairs(projectiles) do
            if not projectile.exists then
                projectiles[i] = nil
            end
        end
    end
end

function love.draw()
    love.graphics.clear()

    -- walls
    love.graphics.setColor(0.5, 0.5, 0.5) -- gray
    for _, wall in pairs(walls) do
        love.graphics.rectangle("fill", wall.x, wall.y, wall.w, wall.h)
    end    

    -- interface
    local life = players[username].life
    local shots = players[username].shots
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("life: " .. life .. " | shots: " .. shots, 32, 1)
    
    -- players
    for _, player in pairs(players) do
        if player ~= nil then
            player:draw()
        end
    end
    
    -- projectiles
    for _, projectile in pairs(projectiles) do
        projectile:draw()
    end
end

local w, h = love.graphics.getDimensions()
print(w, h)

function love.keypressed(key)
    if key == 'escape' then
        local t = {name = username}
        print(serialize(t))
        mqtt_client:publish("trabalho4/sd/unjoined", serialize(t))
        love.event.quit()
        return
    end

    local t = {name = username, keypressed = key}
    print(serialize(t))
    mqtt_client:publish("trabalho4/sd/keypressed", serialize(t))
    players[username]:keypressed(key)
end

function love.keyreleased(key)
    t = {name = username, keyreleased = key}
    print(serialize(t))
    mqtt_client:publish("trabalho4/sd/keyreleased", serialize(t))
    players[username]:keyreleased(key)
end

-----------------------------------------------------
--
--  Auxiliary
--
-----------------------------------------------------

-- returns true if two boxes overlap, false if they don't
-- x, y are the top-left coordinates, while w, h are width and height
function check_collision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

-- checks for collisions with the walls
function hitwall(x, y, w, h)
    for _, wall in pairs(walls) do
        if check_collision(x, y, w, h, wall.x, wall.y, wall.w, wall.h) then
            return true
        end
    end
    return false
end

-- checks for collisions with other players
function hitplayer(player)
    for _, p in pairs(players) do
        local collided = check_collision(
            player.x,
            player.y,
            Player.size,
            Player.size,
            p.x,
            p.y,
            Player.size,
            Player.size
        )
        if p.name ~= player.name and collided then
            return true
        end
    end
    return false
end
