local platforms = {}
local bx = -25

local barrier = { x = -infty, y = 0, w = 6, h = 128, barrier = true }

local bw = 6
local bg = 4

local new_barrier_clock = 0

add_time = 0.5
local ema = 1/128

local player_relax_time = 0.7

local function update_body()
    barrier.w = bx - barrier.x
end

function environment_init()
    physics:add(barrier, true)
    events:register("camera_reset", function(offset)
        bx -= offset
        update_body()
    end)
end

function update_environment()
    physics:del(barrier)
    new_barrier_clock += delta_t
    if new_barrier_clock >= add_time then
        bx += bw + bg
        new_barrier_clock = 0
    end

    --- number of steps until hitting player
    local step_gap = (player.x - bx) / (bw + bg) - (new_barrier_clock / add_time)
    local add_time_proposed
    if step_gap > 0 then
        add_time_proposed = player_relax_time / step_gap
        add_time_proposed = min(add_time_proposed, add_time)
    else
        add_time_proposed = add_time
    end
    add_time = add_time * (1 - ema) + (add_time_proposed * 1.1) * ema

    update_body()
    physics:add(barrier, true)
end

function draw_environment()
    local color = 5
    for i = 1, 10 do
        local x = bx - (i - 1) * (bw + bg)
        rectfill(x - bw, 0, x, 128, color)
    end
    local nx = bx + bw + bg
    local t = new_barrier_clock / add_time
    rectfill(nx - bw, 0, nx, flr(t * 128), color)
end
