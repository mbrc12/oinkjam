infty = 16000 -- allow 2xinfty
delta_t = 1 / 60
player_speed = 50
gravity = 400
epsilon = 0.0001
moon_x = 100
moon_y = 20

building_decay_multiplier = 0 --.08
max_building_height_diff = 10
flat_building_chance = 0.3

jump_forgive_time = 0.1
coyote_time = 0.1
jump_velocity = 150

floor_y = 100

floor = {
    x = -infty,
    y = floor_y,
    w = 2 * infty,
    h = infty,
}

player = {
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    flip = false,
    grounded = false,

    last_jump_asked = 0,
    last_grounded = 0,

    hp = 15,
    max_hp = 20,

    -- never touched
    w = 8,
    h = 4,
    colors = { 2, 14 },
}

function player_center()
    return player.x + player.w / 2, player.y + player.h / 2
end

function _init()
    camera_register_entity(player, 1)
    physics:add(player)
    physics:add(floor, true)
    dbg("init")
end

function minimal_collision(x, y, w, h, x2, y2)
    local earliest_t = 1
    local xf, yf = x2, y2

    ---@param other any
    ---@param result HitResult
    local function work(other, result)
        if result.t < earliest_t then
            earliest_t = result.t
            xf, yf = result.tx, result.ty
        end
    end
    physics:query(x, y, w, h, x2, y2, work)
    return xf, yf
end

function update_player()
    physics:del(player)

    local local_gravity = gravity

    if isdown("interact") or isdown("up") then
        player.last_jump_asked = time()
    else
        local_gravity = gravity * 2
    end

    local dir = direction()
    player.vy = min(200, player.vy + local_gravity * delta_t)
    player.vx = dir.x * player_speed


    if time() - player.last_jump_asked < jump_forgive_time and
        time() - player.last_grounded < coyote_time then
        player.vy = -jump_velocity
    end

    --- do collision in two steps to allow sliding on walls
    local x2, y2 = player.x + player.vx * delta_t, player.y + player.vy * delta_t
    local sx, sy = minimal_collision(player.x, player.y, player.w, player.h, x2, player.y)
    local sx2, sy2 = minimal_collision(sx, sy, player.w, player.h, sx, y2)
    if player.vy > 0 and abs(sy2 - player.y) < epsilon then
        player.grounded = true
        player.last_grounded = time()
    else
        player.grounded = false
    end
    player.vx = (sx2 - player.x) / delta_t
    player.vy = (sy2 - player.y) / delta_t
    player.x, player.y = sx2, sy2

    physics:add(player)
end

local over = false

---@class Bullet
---@field x number
---@field y number
---@field vx number
---@field vy number
---@field w number
---@field h number
---@field elapsed number
---@field show_time number
---@field color number
---@type table<Bullet, boolean>
local bullets = {}

function update_bullets()
    if time() % 1 < 0.1 then
        local moon_pos = Vec2:new(moon_x + camera_offset(1) + 4, moon_y + 4)
        local px, py = player_center()
        local dir = Vec2:new(px - moon_pos.x, py - moon_pos.y)
        dir:scl(1 / (dir:len() + epsilon)):clip(1)
        local bullet_speed = 50
        local bullet = {
            x = moon_pos.x,
            y = moon_pos.y,
            w = 1,
            h = 1,
            vx = dir.x * bullet_speed,
            vy = dir.y * bullet_speed,
            elapsed = 0,
            show_time = 0.1,
            color = 8,
        }

        bullets[bullet] = true
        camera_register_entity(bullet, 1)
    end
    ---
    local todelete = {}

    for b, _ in pairs(bullets) do
        if b.x < player.x - 200 or b.x > player.x + 200 or
            b.y < player.y - 200 or b.y > player.y + 200 then
            add(todelete, b)
            goto continue
        end

        b.elapsed = b.elapsed + delta_t
        local x2, y2 = b.x + b.vx * delta_t, b.y + b.vy * delta_t
        x2, y2 = round(x2), round(y2)
        local done = false
        local injure = false
        physics:query(b.x, b.y, b.w, b.h, x2, y2, function(other, _)
            if other == player then
                player.hp = player.hp
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
            end
            add(queued_draws, f)
        else
            b.x, b.y = x2, y2
        end

        ::continue::
    end
    for _, b in ipairs(todelete) do
        camera_remove_entity(b, 1)
        bullets[b] = nil
    end
end

function _update60()
    if over then
        return
    end
    update_buildings()
    update_player()
    update_bullets()
    -- player.hp = max(0, player.hp - 1)
    if player.hp <= 0 then
        over = true
    end

    --- stopgap to prevent memory leaks
    physics:rebuild()
end

-----

---@type fun()[]
queued_draws = {}

function _draw()
    if over then
        printcentered("damn", 40, 8)
        printcentered("its over", 50, 8)
        return
    end

    camera_move(player.x - 20, 1)

    cls(0)

    line(0, floor_y, infty, floor_y, 5)
    sprite("moon", moon_x, moon_y)


    camera_enable(1)

    draw_buildings()

    local t = time()

    if player.vx < -epsilon then
        player.flip = true
    elseif player.vx > epsilon then
        player.flip = false
    end

    if abs(player.vx) < epsilon then
        sprite("player", player.x, player.y, player.flip)
    else
        anim("player_run", t, 20 + camera_offset(1), player.y, player.flip)
    end

    for b, _ in pairs(bullets) do
        if b.elapsed > b.show_time then
            pset(b.x, b.y, b.color)
        end
    end

    --- queued draws
    filter(queued_draws, function(f)
        local done = f()
        return not done
    end)

    -- physics:draw(false)

    camera()

    draw_sludge()
    draw_hp()

    draw_msg()
end

function draw_hp()
    local hp_h = 4
    local hp_w = 50
    local hp_x = 2
    local hp_y = hp_x
    local l = player.hp / player.max_hp * hp_w
    rectfill(hp_x, hp_y, hp_x + l, hp_y + hp_h, 8)
    rect(hp_x, hp_y, hp_x + hp_w, hp_y + hp_h, 2)
end

function draw_sludge()
    local sludge_color = 5

    local wavelength = { 120, 80 }
    local period = { 5, 3 }
    local amp = { 3, 1.5 }

    for x = 0, 128 do
        local lx = x + camera_offset(1)
        local val = 0
        for i = 1, 2 do
            local cur = sin(2 * 3.14 * (lx / wavelength[i] - time() / period[i]))
            val = val + (1 + cur) * amp[i]
        end
        local y = flr(val / 3)
        line(x, floor_y - y, x, 128, sludge_color)
    end
end

function draw_msg()
    local msg = "x: " .. round(player.x)
    -- local time_since_grounded = time() - player.last_grounded
    -- msg = msg .. "g:" .. (player.grounded and "t" or "f") .. " gt: " .. round(time_since_grounded) / 100
    msg = msg .. "b:" .. mapsize(bullets)
    msg = msg .. "m:" .. stat(0)
    msg = msg .. " bc: " .. #buildings
    print(msg, 2, 128 - 8, 0)
end
