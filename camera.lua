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
    if cam.x < camera_reset_threshold then
        return
    end

    -- logic to reset camera and all entities positions to avoid precision issues
    cam.x -= camera_reset_threshold
    for entity, _ in pairs(cam.entities) do
        entity.x -= camera_reset_threshold
    end
    next_building_x -= camera_reset_threshold
    physics:rebuild()
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
