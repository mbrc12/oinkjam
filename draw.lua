---@enum (key) Sprite
local sprites = {
    snake1 = { idx = 20 },
    snake2 = { idx = 21 },
    snake3 = { idx = 22 },
    heart = { idx = 6 },
}

---@enum (key) Anim
local anims = {
    -- player_run = { idxs = { 1, 2, 3 }, speed = 0.1, w = 1, h = 1, loop = true },
    -- bullet_finish = { idxs = { 54, 55, 56, 57, 58 }, speed = 0.05, w = 1, h = 1, loop = false },
    -- rat = { idxs = { 66, 67 }, speed = 0.2, w = 1, h = 1, loop = true },
    -- snake = { idxs = { 69, 70, 71, 72 }, speed = 0.15, w = 1, h = 1, loop = true },

    player = { idxs = { 8, 9, 10, 11, 12, 13 }, speed = 0.1, w = 1, h = 1, loop = true, pingpong = true },
    pigdown = { idxs = { 103, 105, 107, 109 }, w = 2, h = 2, speed = 0.1, loop = true },
    pigright = { idxs = { 71, 73, 75, 77 }, w = 2, h = 2, speed = 0.1, loop = true },
}

function rotate_sprite(src, dst, w, h)
  local sx = src % 16 * 8
  local sy = src \ 16 * 8
  local dx = dst % 16 * 8
  local dy = dst \ 16 * 8
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      sset(dx + h - 1 - y, dy + x, sget(sx + x, sy + y))
    end
  end
end

function sprsd(idx, x, y, w, h)
    for i = 1, 15 do
        pal(i, shadow_color)
    end
    spr(idx, x, y + 1, w, h)
    pal()
    spr(idx, x, y, w, h)
end

---@param name Sprite
---@param x number
---@param y number
---@param flipx? boolean
---@param flipy? boolean
function sprite(name, x, y, flipx, flipy)
    local item = sprites[name]
    x = round(x)
    y = round(y)
    if not item then
        print("Sprite '" .. name .. "' not found")
        return
    end
    local w = item.w or 1
    local h = item.h or 1
    spr(item.idx, x, y, w, h, flipx or false, flipy or false)
end

---@param name Anim
---@param t number
---@param x number
---@param y number
---@param flipx? boolean
---@param flipy? boolean
---@param shadow? boolean should draw shadow (for player animation)
---@return boolean true if animation ended (only for non-looping animations)
function anim(name, t, x, y, flipx, flipy, shadow)
    local item = anims[name]
    x = round(x)
    y = round(y)
    if not item then
        print("Anim '" .. name .. "' not found")
    end
    local frame = flr(t / item.speed)
    local count = #item.idxs
    if frame >= count then
        if item.loop == false then
            return true
        end
        if item.pingpong then
            frame = frame % (count * 2)
            if frame >= count then
                frame = count * 2 - frame - 1
            end
        else
            frame = frame % #item.idxs
        end
    end
    local idx = item.idxs[frame + 1]
    local w = item.w or 1
    local h = item.h or 1
    local drawer = shadow and sprsd or spr
    drawer(idx, x, y, w, h, flipx or false, flipy or false)
    return false
end
