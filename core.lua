infty = 16000 -- allow 2xinfty
delta_t = 1 / 30
player_speed = 100
gravity = 400
building_decay_rate = 0.1

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

--- Buildings are top to bottom
---@class Building 
---@field x number floor x
---@field w number 
---@field h number
---@field decay number
---@field seed number
---@type Building[]
local buildings = {}

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
local next_building_x = 0

function update_buildings()
    local function new_building(lh)
        local w = rand_geom(1 / 3) * 2 + 6
        local h = rand_geom(1 / 8) * 2 + 6
        h = min(lh + 10, h)
        return {
            x = next_building_x,
            w = w,
            h = h,
            decay = rnd() * 0.4,
            seed = getseed(),
        }
    end

    local todelete = {}

    for _, b in ipairs(buildings) do
        b.decay = b.decay or 0
        if rnd() < b.decay then
            b.h -= 2
        end
        if b.h <= 0 or b.x + b.w < player.x - 200 then
            add(todelete, b)
        end
    end

    for _, b in ipairs(todelete) do
        camera_remove_entity(b, 1)
        del(buildings, b)
    end

    while next_building_x < player.x + 200 do
        local h = #buildings > 0 and buildings[#buildings].h or 0
        local b = new_building(h)
        camera_register_entity(b, 1)
        add(buildings, b)

        next_building_x = b.x + b.w + 4
    end
end

---@param b Building
function draw_building(b)
    rect(b.x, floor_y - b.h - 1, b.x + b.w, floor_y, 5)
    setseed(b.seed)
    local window_chance = 0.3
    for x = b.x + 2, b.x + b.w - 2, 2 do
        for y = floor_y - b.h + 1, floor_y - 3, 2 do
            if rnd() < window_chance then
                local color = rnd() < 0.5 and 9 or 5
                pset(x, y, color)
            end
        end
    end
    -- print(round(b.decay*100), b.x, floor_y - b.h - 10, 7)
    unseed()
end

function draw_buildings()
    for _, b in ipairs(buildings) do
        draw_building(b)
    end
end

-------------------------

-- local camera_speed = 0.05
local camera_reset_threshold = 1000
local camera_default_x = 0

local cameras = {}
local function ensure_camera(n)
    n = n or 1
    if not cameras[n] then
        cameras[n] = { x = camera_default_x, entities = {} }
    end
end

ensure_camera(1)

--- must have x position
---@param entity table
---@param n? number camera layer
function camera_register_entity(entity, n)
    n = n or 1
    ensure_camera(n)
    cameras[n].entities[entity] = true
end

---@param entity table
---@param n? number camera layer
function camera_remove_entity(entity, n)
    n = n or 1
    ensure_camera(n)
    cameras[n].entities[entity] = nil
end

---@param x number
---@param n? number camera layer
function camera_move(x, n)
    n = n or 1
    ensure_camera(n)
    local cam = cameras[n]
    -- cam.x = cam.x + (x - cam.x) * camera_speed
    cam.x = round(x)
    if cam.x > camera_reset_threshold then
        cam.x -= camera_reset_threshold
        for entity, _ in pairs(cam.entities) do
            entity.x -= camera_reset_threshold
        end
        next_building_x -= camera_reset_threshold
    end
end

---@param n? number camera layer
function camera_enable(n)
    n = n or 1
    ensure_camera(n)
    camera(cameras[n].x, 0)
end

function get_camera(n)
    n = n or 1
    ensure_camera(n)
    return cameras[n].x
end
