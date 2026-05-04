---@alias EventType "camera_reset"

events = {
    ---@type table<EventType, (fun(...):boolean)[]>
    cb = {}
}

function events:init()
    self.cb = {}
end

---@param e EventType
---@param handler fun(...):boolean?
function events:register(e, handler)
    if not self.cb[e] then
        self.cb[e] = {}
    end
    add(self.cb[e], handler)
end

---@param e EventType
function events:trigger(e, ...)
    local args = { ... }
    if not self.cb[e] then
        return
    end
    filter(self.cb[e], function(handler)
        local todelete = handler(unpack(args))
        if todelete == nil then
            return true
        end
        return not todelete
    end)
end
