---@class Vec2
vec2 = { x = 0, y = 0 }
vec2.__index = vec2

---@param x? number
---@param y? number
---@return Vec2
function vec2:new(x, y)
    return setmetatable({ x = x or 0, y = y or 0 }, self)
end

---@param other Vec2
---@return Vec2 self
function vec2:add(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    return self
end

---@param x number
---@param y number
---@return Vec2 self
function vec2:add2(x, y)
    self.x = self.x + x
    self.y = self.y + y
    return self
end

---@param s number
---@return Vec2 self
function vec2:scl(s)
    self.x = self.x * s
    self.y = self.y * s
    return self
end

---@param max number
---@return Vec2 self
function vec2:clip(max)
    local len = self:len()
    if len > max then
        self:scl(max / len)
    end
    return self
end

---@return number
function vec2:len()
    return sqrt(self.x * self.x + self.y * self.y)
end

function vec2:unit()
    local len = self:len()
    if len > 0 then
        self:scl(1 / len)
    end
    return self
end

