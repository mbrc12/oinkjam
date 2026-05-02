infty = 16000 -- allow 2xinfty
delta_t = 1 / 30
player_speed = 100

floor_y = 90

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
    dir.y *= player_speed
    dir.x *= player_speed
    local x2, y2 = player.x + dir.x * delta_t, player.y + dir.y * delta_t
    local result = hit(
        player.x, player.y, player.w, player.h,
        floor.x, floor.y, floor.w, floor.h,
        x2, y2
    )
    dbg(result)
    if result then
        player.x, player.y = result.tx, result.ty
    else
        player.x, player.y = x2, y2
    end
    camera_move(player.x, 1)
end

function draw_physics()
    local entities = { floor, player }
    for _, r in ipairs(entities) do
        rect(r.x, r.y, r.x + r.w, r.y + r.h, 8)
    end
end

function _draw()
    cls(0)
    rectfill(0, floor_y, 128, 128, 5)
    sprite("moon", 100, 20)


    camera_enable(1)

    local t = time()
    anim("player_run", t, player.x, player.y)

    camera()
end

-------------------------

local camera_speed = 0.05
local camera_reset_threshold = 1000
local camera_default_x = -20

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
    cam.x = cam.x + (x - cam.x) * camera_speed
    if cam.x > camera_reset_threshold then
        cam.x -= camera_reset_threshold
        for entity, _ in pairs(cam.entities) do
            entity.x -= camera_reset_threshold
        end
    end
end

---@param n? number camera layer
function camera_enable(n)
    n = n or 1
    ensure_camera(n)
    camera(cameras[n].x, 0)
end
