local tstr = require 'tstr'

local p = {}
p.__index = p

function p:new(name, x, y, r, g, b)
  local p = {}
  setmetatable(p, p)

  p.name = name
  p.x = x
  p.y = y
  p.size = 20
  p.life = 10
  p.shots = 100
  p.speedx = 0
  p.speedy = 0
  p.direction = "r"
  p.r = r
  p.g = g
  p.b = b
  p.shot = false

  local size_div_two = p.size/2

  local r = 0
  local g = 0
  local b = 0
  if p.r > 0.5*255 then r = 0 else r = 1 end
  if p.g > 0.5*255 then g = 0 else g = 1 end
  if p.b > 0.5*255 then g = 0 else b = 1 end

  local player_speed = 50


  p.draw = function ()
    love.graphics.setColor(p.r, p.g, p.b)
    love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)

    love.graphics.setColor(r, g, b)
    local x = p.x
    local y = p.y
    if p.direction == 'r' then
      x = p.x + p.size - 5
      y = p.y + size_div_two
    elseif p.direction == 'l' then
      x = p.x + 5
      y = p.y + size_div_two
    elseif p.direction == 'u' then
      x = p.x + size_div_two
      y = p.y + 5
    elseif p.direction == 'd' then
      x = p.x + size_div_two
      y = p.y + p.size - 5
    end
    love.graphics.ellipse("fill", x, y, 3, 3)
  end

  p.keypressed = function (key)
    if key == "w" then
        p.speedy = -player_speed
        p.speedx = 0
        p.direction = "u"
    elseif key == "s" then
        p.speedy = player_speed
        p.speedx = 0
        p.direction = "d"
    elseif key == "a" then
        p.speedx = -player_speed
        p.speedy = 0
        p.direction = "l"
    elseif key == "d" then
        p.speedx = player_speed
        p.speedy = 0
        p.direction = "r"
    elseif key == "space" then
        if p.shots > 0 then
            p.shot = true
            p.shots = p.shots - 1
        end
    end
  end

  p.keyreleased = function (key)
    if key == "w" then
        p.speedy = 0
    elseif key == "s" then
        p.speedy = 0
    elseif key == "a" then
        p.speedx = 0
    elseif key == "d" then
        p.speedx = 0
    elseif key == "space" then
        p.shot = false
    end
  end

  p.join_info = function ()
    t = { name = p.name, x = p.x, y = p.y, r = p.r, g = p.g, b = p.b }
    return serialize(t)
  end

  return p
end

function p:__tostring()
  local s = ""
  for i, v in pairs(self) do s = s .. i .. "\t" ..  tostring(v) .. "\n" end
  return s
end

return p
