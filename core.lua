pos = Vec2:new()
speed = 50
DT = 1 / 30


function _update()
    local dir = direction()
    pos:add(dir:scl(speed * DT))
    dbg(pos, dir)
end

function _draw()
    sprite("parachute", pos.x, pos.y)
end
