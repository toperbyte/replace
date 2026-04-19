local l = {
    c = setmetatable({}, {__mode = "kv"}),
    s = {}
}

l.p = function(t, p, v)
    local k = p:split(".")
    local cur = t
    for i = 1, #k - 1 do
        if not cur[k[i]] then cur[k[i]] = {} end
        cur = cur[k[i]]
    end
    cur[k[#k]] = v
end

l.t = function(t, q, v)
    local function r(o)
        if type(o) ~= "table" or l.c[o] then return end
        l.c[o] = true
        for k, val in next, o do
            if k == q then
                rawset(o, k, v)
            elseif type(val) == "table" then
                r(val)
            end
        end
    end
    r(t)
    l.c = setmetatable({}, {__mode = "kv"})
end

l.m = function(t, k, f)
    local o = t[k]
    t[k] = function(...)
        return f(o, ...)
    end
end

l.v = function(t, k, v)
    local p = v
    setmetatable(t, {
        __index = function(s, n)
            if n == k then return p end
            return rawget(s, n)
        end,
        __newindex = function(s, n, nv)
            if n == k then p = v return end
            rawset(s, n, nv)
        end
    })
end

l.f = function(t, d)
    for k, v in next, d do
        if type(v) == "table" and type(t[k]) == "table" then
            l.f(t[k], v)
        else
            rawset(t, k, v)
        end
    end
end

l.w = function(t, k, v)
    task.spawn(function()
        while true do
            t[k] = v
            task.wait()
        end
    end)
end

l.x = function(s, e)
    local d = {}
    for i = 1, #s do
        d[i] = string.char(s:byte(i) + e)
    end
    return table.concat(d)
end

l.i = function(m, k, v)
    local s, r = pcall(require, m)
    if s then
        l.t(r, k, v)
    end
end

l.o = function(t, c)
    local p = {}
    return setmetatable(p, {
        __index = t,
        __call = function(_, ...)
            return c(t, ...)
        end
    })
end

l.b = function(t, q)
    local r = {}
    local function s(o, y)
        if type(o) ~= "table" or l.c[o] then return end
        l.c[o] = true
        for k, v in next, o do
            local p = y .. "." .. tostring(k)
            if tostring(k):find(q) or tostring(v):find(q) then
                r[p] = v
            end
            if type(v) == "table" then s(v, p) end
        end
    end
    s(t, "root")
    l.c = setmetatable({}, {__mode = "kv"})
    return r
end

return l
