---@enum (key) Sprite
local sprites = {
    parachute = { idx = 16, w = 1, h = 1 },
    dirt_monster = { idx = 64, w = 2, h = 2 },
}

---@param name Sprite
---@param x number
---@param y number
function sprite(name, x, y)
    local item = sprites[name]
    x = round(x)
    y = round(y)
    if not item then
        print("Sprite '" .. name .. "' not found")
    end
    if item then
        local w = item.w or 1
        local h = item.h or 1
        spr(item.idx, x, y, w, h)
    end
end
