local enemies = {}
local proto = {
    rat = {
        w = 6,
        h = 2,
        update = function(e, dt)
            physics:del(e)
        end
    }
}


function spawn_enemy(kind, x, y)
   local e = {
        x = x,
        y = y,
    }
    setmetatable(e, { __index = proto[kind] })
    physics:add(e)
    camera_register_entity(e, 1)
    add(enemies, e)
end
