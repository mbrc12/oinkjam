infty = 16000 -- allow 2xinfty
delta_t = 1 / 60
epsilon = 0.0001
move_dt = 0.04
bsz = 3

local player = {
    x = 64,
    y = 64,
    w = 3,
    h = 3,
    v = 100,
    lastdir = nil,
}

local ax, ay, aw, ah = 14, 16, 100, 96

local walls = {
    left = { x = 0, y = 0, w = ax, h = 128 },
    top = { x = 0, y = 0, w = 128, h = ay },
    right = { x = ax + aw, y = 0, w = ax, h = 128 },
    bot = { x = 0, y = ay + ah, w = 128, h = ah },
}

function _init()
    dbg("init")
    player.blocks = { {64,64+bsz}, {64,64} }
    player.lastdir = vec2:new()
    events:init()
    for i = 0, 3 do -- prepare rotated sprites
        rotate_sprite(103 + 2*i, 71 + 2*i, 16, 16)
    end
    physics:add(walls.left)
    physics:add(walls.top)
    physics:add(walls.right)
    physics:add(walls.bot)
end

local function repr(b)
    dbg("repr", b)
    return b[1] .. "," .. b[2]
end

---@returns boolean true if player collided with itself
function player:move()
    local dir = direction()
    if dir.x == 0 and dir.y == 0 then
        dir = self.lastdir
        return
    else
        self.lastdir.x, self.lastdir.y = dir.x, dir.y
    end

    dir:unit()
    
    local nx, ny = self.x + dir.x * self.v * delta_t, self.y + dir.y * self.v * delta_t
    local x2, y2, bestt = nx, ny, 1
    physics:query(self.x, self.y, self.w, self.h, nx, ny, function(other, result)
        if result.t < bestt then
            bestt = result.t
            x2, y2 = result.tx, result.ty
        end
    end)
    
    self.x, self.y = x2, y2
end

function _update60()
    input_update()
    player:move()

    --- stopgap to prevent memory leaks
    physics:rebuild()
end

-------------------------------------------------------------

---@type (fun():boolean)[]
queued_draws = {}


function player:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h
    x, y = round(x), round(y)
    local dx, dy = self.lastdir.x, self.lastdir.y
    line(x + (w - 1)/2, y + (h - 1)/2, x + (w - 1)/2 - dx*3, y + (h - 1)/2 - dy*3, 6)
    rectfill(x, y, x + w - 1, y + h - 1, 4)
end

---@param x number
---@param y number
---@param look "left"|"right"|"up"|"down"
function pigdraw(x, y, look)
    if look == "down" or look == "up" then
        anim("pigdown", time(), x, y, false, look == "up", true)
    else
        anim("pigright", time(), x, y, look == "right", false, true)
    end
end

function _draw()
    cls(0)
    camera_enable(1)

    rect(0, 0, 127, 127, 1)
    map(0, 0, 8, 8, 14, 14)

    --- queued draws
    queued_draws = filter(queued_draws, function(f)
        local done = f()
        return not done
    end)

    pigdraw(10, 0, "down")

    player:draw()
    -- physics:draw(false)

    camera()
end


