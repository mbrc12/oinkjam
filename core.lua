infty = 16000 -- allow 2xinfty
delta_t = 1 / 30
player_speed = 100
gravity = 400
building_decay_multiplier = 0.08

floor_y = 100

local floor = {
    x = -infty,
    y = floor_y,
    w = 2 * infty,
    h = infty,
}

local player = {
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,

    -- never touched
    w = 8,
    h = 4,
    colors = { 2, 14 },
}

function _init()
    camera_register_entity(player, 1)
end

function minimal_collision(x, y, w, h, x2, y2)
    local earliest_t = 1
    local xf, yf = x2, y2
    ---@param hit HitResult
    local function allow(hit)
        return true
    end
    local function work(box)
        local result = hit(
            x, y, w, h,
            box.x, box.y, box.w, box.h,
            x2, y2
        )
        if result and allow(result) then
            if result.t < earliest_t then
                earliest_t = result.t
                xf, yf = result.tx, result.ty
            end
        end
    end
    work(floor)
    for _, b in ipairs(buildings) do
        work({
            x = b.x,
            y = floor_y - b.h - 1,
            w = b.w,
            h = b.h,
        })
    end
    return xf, yf
end

function update_player()
    local dir = direction()
    player.vy = min(200, player.vy + gravity * delta_t)
    player.vx = dir.x * player_speed

    if isdown("interact", true) then
        player.vy -= 200
    end

    --- do collision in two steps to allow sliding on walls
    local x2, y2 = player.x + player.vx * delta_t, player.y + player.vy * delta_t
    local sx, sy = minimal_collision(player.x, player.y, player.w, player.h, x2, player.y)
    local sx2, sy2 = minimal_collision(sx, sy, player.w, player.h, sx, y2)
    player.vx = (sx2-player.x) / delta_t
    player.vy = (sy2-player.y) / delta_t
    player.x, player.y = sx2, sy2
end

function _update()
    update_buildings()
    update_player()
end

function _draw()
    camera_move(player.x - 20, 1)

    cls(0)
    line(0, floor_y, infty, floor_y, 5)
    sprite("moon", 100, 20)
    print("x: " .. round(player.x) .. " y: " .. round(player.y), 1, 1, 7)

    camera_enable(1)

    draw_buildings()

    local t = time()
    anim("player_run", t, 20 + get_camera(1), player.y)

    -- draw_physics()

    camera()
end

-------------------------

-------------------------

function draw_physics()
    local entities = { floor, player }
    for _, r in ipairs(entities) do
        rect(r.x, r.y, r.x + r.w, r.y + r.h, 8)
    end
end

-------------------------

-------------------------
