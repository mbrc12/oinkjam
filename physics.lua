local cellsize = 16

--- any item put here must have x, y, w, h, cat, mask
--- if an item is large (like the floor), it will be checked against all other items, so it should be used only for items that are very large and few in number
physics = {
    large_items = {},
    items = {},
    cells = {},
}

local function repr(cx, cy)
    return cx .. "," .. cy
end

local function unrepr(s)
    local parts = split(s, ",")
    return tonum(parts[1]), tonum(parts[2])
end

local function compute_cells(x, y, w, h)
    local cells = {}
    local x1 = flr(x / cellsize)
    local y1 = flr(y / cellsize)
    local x2 = flr((x + w) / cellsize)
    local y2 = flr((y + h) / cellsize)
    for cy = y1, y2 do
        for cx = x1, x2 do
            add(cells, repr(cx, cy))
        end
    end
    return cells
end

---@param item any
---@param large? boolean
function physics:add(item, large)
    large = large or false
    if large then
        self.large_items[item] = true
        return
    end
    local cells = compute_cells(item.x, item.y, item.w, item.h)
    self.items[item] = cells
    for _, c in ipairs(cells) do
        if not self.cells[c] then
            self.cells[c] = { item }
        else
            add(self.cells[c], item)
        end
    end
end

function physics:del(item)
    if self.large_items[item] then
        self.large_items[item] = nil
        return
    end
    local cells = self.items[item]
    for _, c in ipairs(cells) do
        del(self.cells[c], item)
    end
    self.items[item] = nil
end

function physics:rebuild()
    -- no need to rebuild large items, they are checked against all other items
    self.cells = {}
    for item, _ in pairs(self.items) do
        self:add(item)
    end
end

--- for this to work, speed of anything should not exceed two cells per frame, 
--- which is 32*30 = 960
---@param x number
---@param y number
---@param w number
---@param h number
---@param gx number goal x
---@param gy number goal y
---@param process fun(other: any, result: HitResult)
function physics:query(x, y, w, h, gx, gy, process)
    local current_cells = compute_cells(x, y, w, h)
    local goal_cells = compute_cells(gx, gy, w, h)

    local visited = {}

    local function work(other)
        if visited[other] then
            return
        end

        visited[other] = true

        local result = hit(
            x, y, w, h,
            other.x, other.y, other.w, other.h,
            gx, gy
        )
        if result then
            process(other, result)
        end
    end

    for _, c in ipairs(goal_cells) do
        for _, o in ipairs(self.cells[c]) do
            work(o)
        end
    end
    for _, c in ipairs(current_cells) do
        for _, o in ipairs(self.cells[c]) do
            work(o)
        end
    end
    for other, _ in pairs(self.large_items) do
        work(other)
    end
end

function physics:draw()
    for c in pairs(self.cells) do
        for _, o in ipairs(self.cells[c]) do
            dbg("cell: ", c, "item: ", o)
        end
    end

    for item, _ in pairs(self.items) do
        dbg("item: ", item)
        dbg("cells: ", self.items[item])
        for _, c in ipairs(self.items[item]) do
            local cell = {unrepr(c)}
            rect(cell[1] * cellsize, cell[2] * cellsize, cell[1] * cellsize + cellsize, cell[2] * cellsize + cellsize, 1)
        end
        rect(item.x, item.y, item.x + item.w, item.y + item.h, 8)
    end
    for item, _ in pairs(self.large_items) do
        rect(item.x, item.y, item.x + item.w, item.y + item.h, 2)
    end
end
