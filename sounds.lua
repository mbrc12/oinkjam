---@enum (key) Sounds
sounds = {
    land = {0, 0} ,
    sludge = {1, 1},
    hit = {2, 0},
    heartloss = {4, 0},
    eat = {5, 0},
    eatbig = {6, 0}
}


---@param name Sounds
---@param interrupt boolean if interrupt, then stop the previous and play
function sound(name, interrupt)
    local key = sounds[name][1]
    local chan = sounds[name][2]
    if interrupt then
        sfx(-1, chan) -- stop
        sfx(key, chan) -- play
    else
        if stat(46+chan) < 0 then -- if not playing
            sfx(key, chan) -- play
        end
    end
end

---@param name Sounds
function stopsound(name)
    local key = sounds[name][1]
    sfx(key, -2)
end

function silence()
    for i = 0, 3 do
        sfx(-1, i)
    end
end
