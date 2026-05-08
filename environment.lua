
local bx = -25
local barrier = { x = -infty, y = 0, w = 6, h = 128, barrier = true }
local bw = 6
local bg = 4
local new_barrier_clock = 0
add_time = 0.5
local ema = 1/128
local player_relax_time = 0.7

local function update_barrier_body()
    barrier.w = bx - barrier.x
end


function update_barrier()
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
    -- add_time = add_time * (1 - ema) + (add_time_proposed * 1.1) * ema
    local change = add_time - add_time_proposed
    if change < 0.1 then
        change = 0
    end
    add_time = add_time - change * ema

    update_barrier_body()
    physics:add(barrier, true)
end

function draw_barrier()
    local color = 5
    for i = 1, 10 do
        local x = bx - (i - 1) * (bw + bg)
        rectfill(x - bw, 0, x, 128, color)
    end
    local nx = bx + bw + bg
    local t = new_barrier_clock / add_time
    rectfill(nx - bw, 0, nx, flr(t * 128), color)
end

local platforms = {}
local pvy = 10

function update_platforms()
    local last = platforms[#platforms]
    if not last or last.x < player.x then
        local endx = last and (last.x + last.w) or player.x
        local endy = last and last.y or floor_y
        local nx = endx + flr(rnd(16))
        local w = flr(rnd(16)) + 8
        local ny = endy + flr(rnd(30)) - 15
        add(platforms, { x = nx, y = floor_y, fy = ny, w = w, h = floor_y - ny, platform=true })
        physics:add(platforms[#platforms])
    end
    filter(platforms, function(p)
        if p.x < player.x - 100 then
            return false
        end
        physics:del(p)
        if p.y <= p.fy then
            physics:add(p)
            return true
        end
        local ny = p.y - pvy * delta_t
        physics:query(p.x, p.y, p.w, p.h, p.x, ny, function(other, _)
            if other == player then
                other.y -= p.y - ny
            end
        end)
        physics:add(p)
        return true
    end)
end

function draw_platforms()
    for _, p in ipairs(platforms) do
        rectfill(p.x, p.y, p.x + p.w, p.y + p.h, 3)
    end
end


function update_environment()
    update_barrier()
    update_platforms()
end

function draw_environment()
    draw_barrier()
    draw_platforms()
end

function environment_init()
    physics:add(barrier, true)
    events:register("camera_reset", function(offset)
        bx -= offset
        update_barrier_body()
        for _, p in ipairs(platforms) do
            p.x -= offset
        end
    end)
end
