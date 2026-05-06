local platforms = {}
local bx = -25
local bw = 6
local bg = 4

local new_barrier_clock = 0
local base_add_time = 0.5

local add_time = 0.5
local ema = 0.1

local player_relax_time = 0.7

function environment_init()
    events:register("camera_reset", function(offset)
        bx -= offset
    end)
end

function update_environment()
    --- number of steps until hitting player
    local step_gap = (player.x - bx) / (bw + bg)
    local add_time_proposed
    if step_gap > 0 then
        add_time_proposed = player_relax_time / step_gap
        add_time_proposed = min(add_time_proposed, base_add_time)
    else
        add_time_proposed = base_add_time
    end
    add_time = add_time * (1 - ema) + add_time_proposed * ema

    new_barrier_clock += delta_t
    if new_barrier_clock >= add_time then
        bx += bw + bg
        new_barrier_clock = 0
    end
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
