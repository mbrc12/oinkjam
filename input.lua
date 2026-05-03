---@enum (key) Action
local actions = {
    left = "left",
    right = "right",
    up = "up",
    down = "down",
    interact = "x",
}

---@param x "left"|"right"|"up"|"down"|"o"|"z"|"x"
---@param just? boolean
---@return boolean
local function chkbtn(x, just)
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
    if just then
        return btnp(b)
    end
    return btn(b)
end

---@param action Action
---@param just? boolean
---@return boolean
function isdown(action, just)
    return chkbtn(actions[action], just)
end

---@return Vec2
function direction()
    local dir = Vec2:new(0, 0)
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
