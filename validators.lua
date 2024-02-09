-- GP utilities for validation.

local sx = require("stringex")

local M = {}


-----------------------------------------------------------------------------
-- TODO2 better way to do this?
M.fatal = false
M.depth = 2
function M.set_mode(fatal, depth)
    M.fatal = fatal 
    M.depth = depth
end

-----------------------------------------------------------------------------
function M.is_integer(v) return v ~= nil and math.ceil(v) == v end
function M.is_number(v) return v ~= nil and type(v) == 'number' end
function M.is_string(v) return v ~= nil and type(v) == 'string' end
function M.is_boolean(v) return v ~= nil and type(v) == 'boolean' end
function M.is_function(v) return v ~= nil and type(v) == 'function' end
function M.is_table(v) return v ~= nil and type(v) == 'table' end

-----------------------------------------------------------------------------
function M.val_number(v, min, max, info)
    local ok = M.is_number(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok and M.fatal then
        local s = string.format("Invalid number:%s %s %s", tostring(v), info or "")
        error(s, M.depth) -- who called me
    end
    return ok
end

-----------------------------------------------------------------------------
function M.val_integer(v, min, max, info)
    local ok = M.is_integer(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok and M.fatal then
        local s = string.format("Invalid integer:%s %s", tostring(v), info or "")
        error(s, M.depth) -- who called me
    end
    return ok
end

-----------------------------------------------------------------------------
function M.val_string(v, info)
    local ok = M.is_string(v)
    if not ok and M.fatal then
        local s = string.format("Invalid string:%s %s", tostring(v), info or "")
        error(s, M.depth) -- who called me
    end
    return ok
end

-----------------------------------------------------------------------------
function M.val_boolean(v, info)
    local ok = M.is_boolean(v)
    if not ok and M.fatal then
        local s = string.format("Invalid boolean:%s %s", tostring(v), info or "")
        error(s, M.depth) -- who called me
    end
    return ok
end

-----------------------------------------------------------------------------
function M.val_table(v, info)
    local ok = M.is_table(v)
    if not ok and M.fatal then
        local s = string.format("Invalid table:%s", info or "")
        error(s, M.depth) -- who called me
    end
    return ok
end

-----------------------------------------------------------------------------
function M.val_function(v, info)
    local ok = M.is_function(v)
    if not ok and M.fatal then
        local s = string.format("Invalid function:%s", info or "")
        error(s, M.depth) -- who called me
    end
    return ok
end

-----------------------------------------------------------------------------
-- Return the module.
return M
