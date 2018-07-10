require("tstr")

local Player = {}
Player.__index = Player

Player.size = 20

function Player.new(name, x, y, r, g, b)
    local p = {
        name      = name,
        x         = x,
        y         = y,
        size      = size,
        life      = 10,
        shots     = 100,
        speedx    = 0,
        speedy    = 0,
        direction = "r",
        r         = r,
        g         = g,
        b         = b,
        shot      = false
    }
    setmetatable(p, Player)
    return p
end

function Player:draw()
    love.graphics.setColor(self.r, self.g, self.b)
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size)

    local x = self.x
    local y = self.y
    local halfsize = self.size / 2

    if self.direction == "r" then
        x = self.x + self.size - 5
        y = self.y + halfsize
    elseif self.direction == "l" then
        x = self.x + 5
        y = self.y + halfsize
    elseif self.direction == "u" then
        x = self.x + halfsize
        y = self.y + 5
    elseif self.direction == "d" then
        x = self.x + halfsize
        y = self.y + self.size - 5
    end

    local half255 = 127.5
    local r = (self.r > half255) and 0 or 1
    local g = (self.g > half255) and 0 or 1
    local b = (self.b > half255) and 0 or 1

    love.graphics.setColor(r, g, b)
    love.graphics.ellipse("fill", x, y, 3, 3)
    love.graphics.setColor(0, 0, 0)
    love.graphics.ellipse("line", x, y, 4, 4)
end

function Player:keypressed(key)
    local player_speed = 50
    if key == "w" then
        self.speedy = -player_speed
        self.speedx = 0
        self.direction = "u"
    elseif key == "s" then
        self.speedy = player_speed
        self.speedx = 0
        self.direction = "d"
    elseif key == "a" then
        self.speedx = -player_speed
        self.speedy = 0
        self.direction = "l"
    elseif key == "d" then
        self.speedx = player_speed
        self.speedy = 0
        self.direction = "r"
    elseif key == "space" then
        if self.shots <= 0 then return end
        self.shot = true
        self.shots = self.shots - 1
    end
end

function Player:keyreleased(key)
    if key == "w" then
        self.speedy = 0
    elseif key == "s" then
        self.speedy = 0
    elseif key == "a" then
        self.speedx = 0
    elseif key == "d" then
        self.speedx = 0
    elseif key == "space" then
        self.shot = false
    end
end

function Player:join_info()
    local t = {
        name = self.name,
        x    = self.x,
        y    = self.y,
        r    = self.r,
        g    = self.g,
        b    = self.b
    }
    return serialize(t)
end

function Player:__tostring()
    local s = ""
    for i, v in pairs(self) do
        s = s .. i .. "\t" ..  tostring(v) .. "\n"
    end
    return s
end

return Player
