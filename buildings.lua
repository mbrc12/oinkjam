next_building_x = 0

---@class Building 
---@field x number floor x
---@field y number floor y
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
        if rnd() < flat_building_chance then
            h = 0
        end
        h = min(lh + max_building_height_diff, h)
        return {
            x = next_building_x,
            y = floor_y - h,
            w = w,
            h = h,
            seed = getseed(),
        }
    end

    local todelete = {}

    for i, b in ipairs(buildings) do
        b.decay = b.decay or 0
        if rnd() < b.decay then
            b.h -= 2
        end
        if i >= 2 and b.h > buildings[i-1].h + max_building_height_diff then
            b.h = min(b.h, buildings[i-1].h + max_building_height_diff)
        end
    end

    -- delete a prefix of buildings
    for _, b in ipairs(buildings) do
        if b.h <= 0 or b.x + b.w < player.x - 200 then
            add(todelete, b)
        else
            break
        end
    end

    for _, b in ipairs(todelete) do
        physics:del(b)
        camera_remove_entity(b, 1)
        del(buildings, b)
    end

    while next_building_x < player.x + 200 do
        local h = #buildings > 0 and buildings[#buildings].h or 0
        local b = new_building(h)
        physics:add(b)
        camera_register_entity(b, 1)
        add(buildings, b)

        next_building_x = b.x + b.w + 4
    end
end

---@param b Building
function draw_building(b)
    if b.h <= 0 then return end
    rect(b.x, b.y, b.x + b.w, b.y + b.h, 5)
    setseed(b.seed)
    local window_chance = 0.3
    for x = b.x + 2, b.x + b.w - 2, 2 do
        for y = b.y + 2, b.y + b.h - 2, 2 do
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
