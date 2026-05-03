---@enum (key) Sprite
local sprites = {
    player = { idx = 1 },
    player_jump = { idx = 2 },

    cloud_1 = { idx = 48 },
    cloud_2 = { idx = 49 },
    moon = { idx = 32 },

    parachute = { idx = 16 },
    dirt_monster = { idx = 64, w = 2, h = 2 },
}

---@enum (key) Anim
local anims = {
    player_run = { idxs = { 1, 2, 3 }, speed = 0.1, w = 1, h = 1, loop = true },
    bullet_finish = { idxs = { 54, 55, 56, 57, 58 }, speed = 0.05, w = 1, h = 1, loop = false },
}

---@param name Sprite
---@param x number
---@param y number
---@param flipx? boolean
function sprite(name, x, y, flipx)
    local item = sprites[name]
    x = round(x)
    y = round(y)
    if not item then
        print("Sprite '" .. name .. "' not found")
        return
    end
    local w = item.w or 1
    local h = item.h or 1
    spr(item.idx, x, y, w, h, flipx or false, false)
end


---@param name Anim
---@param t number
---@param x number
---@param y number
---@param flipx? boolean
---@return boolean true if animation ended (only for non-looping animations)
function anim(name, t, x, y, flipx)
    local item = anims[name]
    x = round(x)
    y = round(y)
    if not item then
        print("Anim '" .. name .. "' not found")
    end
    local frame = flr(t / item.speed)
    if frame > #item.idxs then
        if item.loop == false then
            return true
        else
            frame = (frame - 1) % #item.idxs + 1
        end
    end
    local idx = item.idxs[frame]
    local w = item.w or 1
    local h = item.h or 1
    spr(idx, x, y, w, h, flipx or false, false)
    return false
end
