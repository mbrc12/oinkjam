infty = 16000 -- allow 2xinfty
delta_t = 1 / 30
player_speed = 100

floor_y = 100

local floor = {
    x = -infty,
    y = floor_y,
    w = 2 * infty,
    h = infty,
}

local player = {
    x = 0,
    y = floor_y - 4,
    -- never touched
    w = 8,
    h = 4,
    colors = { 2, 14 },
}

function _init()
    camera_register_entity(player, 1)
end

function _update()
    local dir = direction()
    dir.y = 0
    dir.x *= player_speed
    local x2, y2 = player.x + dir.x * delta_t, player.y + dir.y * delta_t
    local result = hit(
        player.x, player.y, player.w, player.h,
        floor.x, floor.y, floor.w, floor.h,
        x2, y2
    )
    if result then
        player.x, player.y = result.tx, result.ty
    else
        player.x, player.y = x2, y2
    end

    update_buildings()
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
---@class Building
---@field x number
---@field w number
---@field h number
---@field decay number
---@field seed number
local buildings = {}
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
            decay = rnd() * 0.1,
            seed = getseed(),
        }
    end

    local todelete = {}

    for _, b in ipairs(buildings) do
        b.decay = b.decay or 0
        if rnd() < b.decay then
            b.h -= 2
        end
        if b.h <= 0 then
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
