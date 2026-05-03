local logfile = "oink/log.txt"
printh("log start", logfile, true)

function prettytable(t)
    local str = "{"
    for k, v in pairs(t) do
        str = str .. tostr(k) .. "=" .. tostr(v) .. ", "
    end
    str = str .. "}"
    return str
end

function zeropad(num, len)
    len = len or 2
    local str = tostr(num)
    while #str < len do
        str = "0" .. str
    end
    return str
end

function dbg(...)
    local args = { ... }
    local str = "[" .. zeropad(stat(83)) .. ":" .. zeropad(stat(84)) .. ":" .. zeropad(stat(85)) .. "] "
    for _, v in ipairs(args) do
        if type(v) == "table" then
            str = str .. prettytable(v) .. ";"
        else
            str = str .. tostr(v) .. ";"
        end
    end
    printh(str, logfile)
end

function round(x)
    return flr(x + 0.5)
end

--------------------------------------- random
local old_seed = 0

---@return number
function getseed()
    return flr(rnd(1) * 20000)
end

---@param seed number
function setseed(seed)
    old_seed = getseed() -- get a random seed to restore later
    srand(seed)
end

function unseed()
    srand(old_seed)
end

---@param p? number
---@return number
function rand_geom(p)
    p = p or 1
    cnt = 1
    while rnd(1) > p do
        cnt = cnt + 1
    end
    return cnt
end

--------------------------------------

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

---------------------------------------

---@param t table
---@return number
function mapsize(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end
