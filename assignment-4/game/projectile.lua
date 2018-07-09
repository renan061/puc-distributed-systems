local Projectile = {}
Projectile.__index = Projectile

function Projectile:new()
    local p = {
        x             = -1,
        y             = -1,
        width         = 10,
        height        = 10,
        speedx        = 0,
        speedy        = 0,
        exists        = false,
        size          = 5,
        default_speed = 250
    }
    setmetatable(p, Projectile)
    return p
end

function Projectile:draw()
    if self.exists then
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)
    end
end

function Projectile:__tostring()
    local s = ""
    for i, v in pairs(self) do s = s .. i .. "\t" ..  tostring(v) .. "\n" end
    return s
end

return Projectile
