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

function zeropad(num, len)
    len = len or 2
    local str = tostr(num)
    while #str < len do
        str = "0" .. str
    end
    return str
end

function dbg(...)
    local args = { ... }
    local str = "[" .. zeropad(stat(83)) .. ":" .. zeropad(stat(84)) .. ":" .. zeropad(stat(85)) .. "] "
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
