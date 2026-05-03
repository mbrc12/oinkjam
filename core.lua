infty = 16000 -- allow 2xinfty
delta_t = 1 / 30
player_speed = 150
gravity = 400
epsilon = 0.0001

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

    -- never touched
    w = 8,
    h = 4,
    colors = { 2, 14 },
}

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

function _update()
    update_buildings()
    update_player()
end

function _draw()
    camera_move(player.x - 20, 1)

    cls(0)

    local msg = "x: " .. round(player.x) .. " y: " .. round(player.y) .. " "
    local time_since_grounded = time() - player.last_grounded
    msg = msg .. "g:" .. (player.grounded and "t" or "f") .. " gt: " .. round(time_since_grounded) / 100 .. " "
    msg = msg .. " bc: " .. #buildings
    print(msg, 1, 1, 7)

    line(0, floor_y, infty, floor_y, 5)
    sprite("moon", 100, 20)

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
        -- if player.grounded then
        anim("player_run", t, 20 + get_camera(1), player.y, player.flip)
        -- else
        --     sprite("player_jump", player.x, player.y, player.flip)
        -- end
    end

    -- physics:draw()

    camera()
end
