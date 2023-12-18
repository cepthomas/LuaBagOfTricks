-- GP utilities for validation.

local sx = require("stringex")

local M = {}

-----------------------------------------------------------------------------
function M.is_integer(v) return math.ceil(v) == v end
function M.is_number(v) return type(v) == 'number' end
function M.is_string(v) return type(v) == 'string' end
function M.is_boolean(v) return type(v) == 'boolean' end
function M.is_function(v) return type(v) == 'function' end
function M.is_table(v) return type(v) == 'table' end

-----------------------------------------------------------------------------
function M.val_number(v, max, min)
    local ok = M.is_number(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        local s = string.format("Invalid number:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_integer(v, max, min)
    local ok = M.is_integer(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        local s = string.format("Invalid integer:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_string(v)
    local ok = M.is_string(v)
    if not ok then
        local s = string.format("Invalid string:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_boolean(v)
    local ok = M.is_boolean(v)
    if not ok then
        local s = string.format("Invalid boolean:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_table(v)
    local ok = M.is_table(v)
    if not ok then
        local s = string.format("Invalid table:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_function(v)
    local ok = M.is_function(v)
    if not ok then
        local s = string.format("Invalid function:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
-- Return the module.
return M
