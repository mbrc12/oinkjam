---@class Bullet
---@field x number
---@field y number
---@field vx number
---@field vy number
---@field w number
---@field h number
---@field damage number
---@field elapsed number
---@field show_time number
---@field color number
---@field step fun(self: Bullet, dt: number): (number, number)
---@type table<Bullet, boolean>
local bullets = {}

---@enum (key) BulletKind
local bullet_protos = {
    moon = {
        w = 1,
        h = 1,
        damage = 1,
        color = 6,
        show_time = 0.05,
        elapsed = 0,
        step = function(b, dt)
            local x2, y2 = b.x + b.vx * dt, b.y + b.vy * dt
            return x2, y2
        end
    },
    rat = {
        w = 2,
        h = 2,
        damage = 5,
        color = 4,
        show_time = 0.05,
        elapsed = 0,
        step = function(b, dt)
            local gravity = 100
            b.vy += gravity * dt
            local x2, y2 = b.x + b.vx * dt, b.y + b.vy * dt
            return x2, y2
        end
    }
}

---@param bullet Bullet
---@param kind BulletKind
function spawn_bullet(bullet, kind)
    assert(bullet_protos[kind], "Unknown bullet kind: " .. kind)
    setmetatable(bullet, { __index = bullet_protos[kind] })
    bullets[bullet] = true
end

function spawn_bullets()
    if time() % 1 < 0.1 then -- moon
        local moon_pos = vec2:new(moon_x + camera_offset(1) + 4, moon_y + 4)
        local px, py = player_center()
        local dir = vec2:new(px - moon_pos.x, py - moon_pos.y):unit()
        local speed = 50
        local bullet = {
            x = moon_pos.x,
            y = moon_pos.y,
            vx = dir.x * speed,
            vy = dir.y * speed,
        }
        spawn_bullet(bullet, "moon")
    end
end

function update_bullets()
    spawn_bullets()
    local todelete = {}

    for b, _ in pairs(bullets) do
        if b.x < player.x - 200 or b.x > player.x + 200 or
            b.y < player.y - 200 or b.y > player.y + 200 then
            add(todelete, b)
            goto continue
        end

        b.elapsed = b.elapsed + delta_t
        local x2, y2 = b:step(delta_t)
        local done = false
        local injure = false
        physics:query(b.x, b.y, b.w, b.h, x2, y2, function(other, _)
            if other == player and not (player.invincible > 0) then
                take_damage()
                injure = true
            end
            done = true
        end)
        if done then
            add(todelete, b)
            local start = time()
            local bx, by = b.x, b.y
            local function f()
                local t = time() - start
                if injure then
                    pal(7, 8)
                end
                anim("bullet_finish", t, bx - 4, by - 4, false)
                pal()
                return true
            end
            add(queued_draws, f)
            if injure then
                sound("hit", true)
            end
        else
            b.x = x2
            b.y = y2
        end

        ::continue::
    end
    for _, b in ipairs(todelete) do
        bullets[b] = nil
    end
end

function draw_bullets()
    for b, _ in pairs(bullets) do
        if b.elapsed > b.show_time then
            local bx, by = round(b.x), round(b.y)
            rectfill(bx, by, bx + b.w - 1, by + b.h - 1, b.color)
        end
    end
end


local enemies = {}

local proto = {
    rat = {
        w = 6,
        h = 2,
        update = function(e, dt)
            physics:del(e)
        end
    }
}


function spawn_enemy(kind, x, y)
   local e = {
        x = x,
        y = y,
    }
    setmetatable(e, { __index = proto[kind] })
    physics:add(e)
    add(enemies, e)
end

function enemies_and_bullets_init()
    events:register("camera_reset", function(offset)
        for e, _ in pairs(enemies) do
            e.x -= offset
        end
        for b, _ in pairs(bullets) do
            b.x -= offset
        end
    end)
end
