next_building_x = 0

--- Buildings are top to bottom
---@class Building 
---@field x number floor x
---@field w number 
---@field h number
---@field decay number
---@field seed number
---@type Building[]
buildings = {}

function update_buildings()
    local function new_building(lh)
        local w = rand_geom(1 / 3) * 2 + 6
        local h = rand_geom(1 / 8) * 2 + 6
        h = min(lh + 10, h)
        return {
            x = next_building_x,
            w = w,
            h = h,
            decay = rnd() * building_decay_multiplier,
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
