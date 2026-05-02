pos = Vec2:new()
speed = 50
DT = 1 / 30

floor_y = 90

function _update()
    local dir = direction()
    pos:add(dir:scl(speed * DT))
    dbg(pos, dir)
end

function _draw()
    cls(0)
    rectfill(0, floor_y, 128, 128, 5)
    sprite("moon", 100, 20)
end
