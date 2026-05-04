---@enum (key) Action
local actions = {
    left = "left",
    right = "right",
    up = "up",
    down = "down",
    interact = "x",
}

local input_history = {
    ---@type table<Action, boolean>
    current = {},
    ---@type table<Action, boolean>
    last = {},
}

---@param x "left"|"right"|"up"|"down"|"o"|"z"|"x"
---@return boolean
local function chkbtn(x)
    just = just or false
    local btns = {
        left = 0,
        right = 1,
        up = 2,
        down = 3,
        o = 4,
        z = 4,
        x = 5,
    }
    local b = btns[x]
    if b == nil then
        return false
    end
    return btn(b)
end

function input_update()
    for action, btn in pairs(actions) do
        input_history.last[action] = input_history.current[action]
        input_history.current[action] = chkbtn(btn)
    end
end

---@param b Action
function isdown(b)
    return input_history.current[b]
end

---@param b Action
function isjustdown(b)
    return input_history.current[b] and not input_history.last[b]
end

---@return Vec2
function direction()
    local dir = vec2:new(0, 0)
    if isdown("left") then
        dir.x = dir.x - 1
    end
    if isdown("right") then
        dir.x = dir.x + 1
    end
    if isdown("up") then
        dir.y = dir.y - 1
    end
    if isdown("down") then
        dir.y = dir.y + 1
    end
    return dir
end
