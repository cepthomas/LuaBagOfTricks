
-- Simple class model. See test_class.lua for implementation.
-- Based on http://lua-users.org/wiki/SimpleLuaClasses. See that url for design details.

function Class(base, init)
    local c = {} -- a new class instance
    if not init and type(base) == 'function' then
        init = base
        base = nil
    elseif type(base) == 'table' then
        -- New class is a shallow copy of the base class.
        for i, v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end
    -- The class will be the metatable for all its objects and they will look up their methods in it.
    c.__index = c

    -- Expose a constructor which can be called by <classname>(<args>).
    local mt = {}
    mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj, c)
        if class_tbl.__init then
            class_tbl.__init(obj, ...)
        else
            -- Init base class.
            if base and base.__init then
                base.__init(obj, ...)
            end
        end
        return obj
    end

    c.__init = init

    -- function is_a()
    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do
            if m == klass then return true end
            m = m._base
        end
        return false
    end

    setmetatable(c, mt)
    return c
end
