local mqtt = require "mqtt_library"
local pl = require "player"
local pr = require "projectile"

math.randomseed(os.time())

joined = false

players = {}
projectiles = {}

function mqttcb(topic, message)
  assert(loadstring(message))()
  print(topic .. ': ' .. m.name)
  if m.name ~= username then
    if topic == 'trabalho4/sd/keypressed' then
      players[m.name].keypressed(m.keypressed)
    elseif topic == 'trabalho4/sd/keyreleased' then
      players[m.name].keyreleased(m.keyreleased)
    elseif topic == 'trabalho4/sd/joined' then
      if players[m.name] == nil then
        --create a copy of the player in my world
        players[m.name] = pl:new(username, m.x, m.y, m.r, m.g, m.b)
        --send my info to new player
        mqtt_client:publish("trabalho4/sd/joined", player.join_info())
      end
    elseif topic == 'trabalho4/sd/unjoined' then
      p = players[m.name]
      p.x = -100; p.y = -100; p.r = 0; p.g = 0; p.b = 0
    end
  end
end

username = arg[2] .. tostring(math.random(99999))

mqtt_client = mqtt.client.create(arg[3], arg[4], mqttcb)
mqtt_client:connect(username)
mqtt_client:subscribe({"trabalho4/sd/keypressed", "trabalho4/sd/keyreleased", "trabalho4/sd/joined", "trabalho4/sd/unjoined"})


function love.load(arg)

  --if arg and arg[#arg] == "-debug" then require("mobdebug").start() end

  w, h = love.graphics.getDimensions()

  player = pl:new(username, math.random(10, w - 10), math.random(10, h - 10), math.random(255), math.random(255), math.random(255))

  if not joined then
    mqtt_client:publish("trabalho4/sd/joined", player.join_info())
    joined = true
  end

  players[username] = player

end

function love.update(dt)
  mqtt_client:handler()

  -- player shot?
  for _, player in pairs(players) do
    if player.shot then
      projectile = pr:new()
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

    -- move bullets
    for i, projectile in pairs(projectiles) do
      if projectile.exists then
        projectile.y = projectile.y + ((projectile.speedy) * dt)
        projectile.x = projectile.x + ((projectile.speedx) * dt)
      end
    end

    player.y = player.y + (player.speedy * dt)
    player.x = player.x + (player.speedx * dt)

    for _, player in pairs(players) do
      for _, projectile in pairs(projectiles) do
        if check_collision(player.x, player.y, player.size, player.size, projectile.x, projectile.y, projectile.size, projectile.size) then
          player.life = player.life - 1
          projectile.exists = false
          if player.life == 0 then
            t = {name = username}
            print(serialize(t))
            mqtt_client:publish("trabalho4/sd/unjoined", serialize(t))
            player.r = 0
            player.g = 0
            player.b = 0
            player.x = -100
            player.y = -100
            --player = nil
            love.event.quit()
          end
        end
      end
    end

    for i, projectile in pairs(projectiles) do
      if projectile.exists == false then
        projectiles[i] = nil
      end
    end
  end
end

function love.draw()
  love.graphics.clear()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("life: " .. players[username].life .. " | shots: " .. players[username].shots, 32, 1)

  for _, player in pairs(players) do
    if player ~= nil then
      player.draw()
    end
  end

  for _, projectile in pairs(projectiles) do
    projectile.draw()
  end
end

function love.keypressed(key)
  if key == 'escape' then
      t = {name = username}
      print(serialize(t))
      mqtt_client:publish("trabalho4/sd/unjoined", serialize(t))
      love.event.quit()
  end

  t = {name = username, keypressed = key}
  print(serialize(t))
  mqtt_client:publish("trabalho4/sd/keypressed", serialize(t))
  players[username].keypressed(key)
end

function love.keyreleased(key)
  t = {name = username, keyreleased = key}
  print(serialize(t))
  mqtt_client:publish("trabalho4/sd/keyreleased", serialize(t))
  players[username].keyreleased(key)
end

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function check_collision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
