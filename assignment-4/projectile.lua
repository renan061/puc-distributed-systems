local Projectile = {}
Projectile.__index = Projectile

function Projectile:new()
   local p = {}
   setmetatable(p, Projectile)

   p.x = -1
   p.y = -1
   p.width = 10
   p.height = 10
   p.speedx = 0
   p.speedy = 0
   p.exists = false
   p.size = 5
   p.default_speed = 250

   p.draw = function ()
     if p.exists then
       love.graphics.setColor(255, 255, 255)
       love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
     end
   end

   return p
end

function Projectile:__tostring()
    local s = ""
    for i, v in pairs(self) do s = s .. i .. "\t" ..  tostring(v) .. "\n" end
    return s
end

return Projectile
