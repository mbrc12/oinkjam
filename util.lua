local logfile = "oink/log.txt"
printh("log start", logfile, true)

function prettytable(t)
    local str = "{"
    for k, v in pairs(t) do
        str = str .. tostr(k) .. "=" .. tostr(v) .. ", "
    end
    str = str .. "}"
    return str
end

function dbg(...)
    local args = { ... }
    local str = ""
    for _, v in ipairs(args) do
        if type(v) == "table" then
            str = str .. prettytable(v) .. ";"
        else
            str = str .. tostr(v) .. ";"
        end
    end
    printh(str, logfile)
end

function round(x)
    return flr(x + 0.5)
end
