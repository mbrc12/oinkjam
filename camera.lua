-- local camera_speed = 0.05
local camera_reset_threshold = 600
local camera_default_x = 0

local cameras = {
    [1] = camera_default_x,
}

---@param x number
---@param n? number camera layer
function camera_move(x, n)
    n = n or 1
    cameras[n] = round(x)
    if cameras[n] < camera_reset_threshold then
        return
    end

    cameras[n] -= camera_reset_threshold
    events:trigger("camera_reset", camera_reset_threshold)
end

---@param n? number camera layer
function camera_enable(n)
    n = n or 1
    camera(cameras[n], 0)
end

---@return number
function camera_offset(n)
    n = n or 1
    return cameras[n]
end
