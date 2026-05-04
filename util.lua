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

---@param a number
---@param b number
---@return number
function rand_int(a, b)
    return flr(rnd(b - a + 1)) + a
end

--------------------------------------

---@param t table
---@return number
function mapsize(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end


---@param text string
---@param y number
---@param c? number color
function printcentered(text, y, c)
    c = c or 7
    local width = #text * 4
    local x = (128 - width) / 2
    print(text, x, y, c)
end

---@generic T
---@param t T[]
---@param fn fun(item: T): boolean
---@return T[]
function filter(t, fn)
    local result = {}
    for _, v in ipairs(t) do
        if fn(v) then
            add(result, v)
        end
    end
    return result
end

---@param t table
---@param items table[]
function addmany(t, items)
    for _, v in ipairs(items) do
        add(t, v)
    end
end
