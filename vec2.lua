---@class Vec2
Vec2 = { x = 0, y = 0 }
Vec2.__index = Vec2

---@param x? number
---@param y? number
---@return Vec2
function Vec2:new(x, y)
    return setmetatable({ x = x or 0, y = y or 0 }, self)
end

---@param other Vec2
---@return Vec2 self
function Vec2:add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    return self
end

---@param x number
---@param y number
---@return Vec2 self
function Vec2:add2(x, y)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

---@param s number
---@return Vec2 self
function Vec2:scl(s)
    self.x = self.x * s
    self.y = self.y * s
    return self
end

---@param max number
---@return Vec2 self
function Vec2:clip(max)
    local len = self:len()
    if len > max then
        self:scl(max / len)
    end
    return self
end

---@return number
function Vec2:len()
    return sqrt(self.x * self.x + self.y * self.y)
end
