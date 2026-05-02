---@enum (key) Sprite
local sprites = {
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
        spr(item.idx, x, y, item.w * 8, item.h * 8)
    end
end
