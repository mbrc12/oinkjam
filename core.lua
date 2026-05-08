infty = 16000 -- allow 2xinfty
delta_t = 1 / 60
epsilon = 0.0001
move_dt = 0.04
bsz = 3

local player = {
    blocks = { },
    blocks_occupied = { },
    last_move = -10,
}

local ax, ay, aw, ah = 14, 16, 99, 96

local walls = {
    left = { x = 0, y = 0, w = ax, h = 128 },
    top = { x = 0, y = 0, w = 128, h = ay },
    right = { x = ax + aw, y = 0, w = ax, h = 128 },
    bot = { x = 0, y = ay + ah, w = 128, h = ah },
}

function _init()
    dbg("init")
    player.blocks = { {64,64+bsz}, {64,64} }
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
    if time() - self.last_move < move_dt then
        return false
    end

    local dir = direction()
    dir:scl(bsz)
    if dir.x == 0 and dir.y == 0 then
        return false
    end
    if dir.x ~= 0 and dir.y ~= 0 then
        return false -- prevent diagonal movement
    end


    local last = self.blocks[#self.blocks]
    local newblock = {last[1]+dir.x, last[2]+dir.y}

    if player.blocks_occupied[repr(newblock)] then
        return true
    end
    
    local allow = true

    local cx, cy, nx, ny = last[1], last[2], newblock[1], newblock[2]
    physics:query(cx, cy, bsz, bsz, nx, ny, function(item)
        if item == walls.left or item == walls.top or item == walls.right or item == walls.bot then
            allow = false
        end
    end)

    if not allow then
        return false
    end

    add(self.blocks, newblock)
    player.blocks_occupied[repr(newblock)] = true
    self.last_move = time()
    return false
end

function _update60()
    input_update()

    local looped = player:move()
    if #player.blocks > 10 then
        local block = player.blocks[1]
        deli(player.blocks, 1)
        dbg(block)
        player.blocks_occupied[repr(block)] = nil
    end
    
    --- stopgap to prevent memory leaks
    physics:rebuild()
end

-------------------------------------------------------------

---@type (fun():boolean)[]
queued_draws = {}


function player:_drawonce(dy)
    setseed(20)

    local block = self.blocks[#self.blocks]
    local neck = self.blocks[#self.blocks - 1]

    if block[1] == neck[1] and block[2] < neck[2] then
        spr(22, block[1], block[2] + dy, 1, 1)
    elseif block[1] == neck[1] and block[2] > neck[2] then
        spr(23, block[1], block[2] + dy, 1, 1)
    elseif block[1] < neck[1] and block[2] == neck[2] then
        spr(24, block[1], block[2] + dy, 1, 1)
    elseif block[1] > neck[1] and block[2] == neck[2] then
        spr(25, block[1], block[2] + dy, 1, 1)
    end

    for i = #self.blocks-1, 1, -1 do
        local sp = 20 + flr(rnd() * 2)
        local block = self.blocks[i]
        spr(sp, block[1], block[2] + dy, 1, 1)
    end

    unseed()
end

function player:draw()
    local shadow_color = 5
    for i = 1, 15 do
        pal(i, shadow_color)
    end
    self:_drawonce(1)
    pal()
    self:_drawonce(0)
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

    --     spr(16, i, areay)
    --     spr(16, i, areay + areah - 4)
    --     spr(16, areax, i)
    --     spr(16, areax + areaw - 4, i)
    -- end
    rect(0, 0, 127, 127, 1)
    map(0, 0, 8, 8, 14, 14)
    -- rect(areax, areay, areax + areaw, areay + areah, 7)

    --- queued draws
    queued_draws = filter(queued_draws, function(f)
        local done = f()
        return not done
    end)

    pigdraw(10, 0, "down")

    player:draw()
    physics:draw(false)

    camera()
end


