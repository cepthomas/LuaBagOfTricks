-- GP utilities for validation.

local sx = require("stringex")

local M = {}


-----------------------------------------------------------------------------
function M.is_integer(v) return v ~= nil and math.ceil(v) == v end
function M.is_number(v) return v ~= nil and type(v) == 'number' end
function M.is_string(v) return v ~= nil and type(v) == 'string' end
function M.is_boolean(v) return v ~= nil and type(v) == 'boolean' end
function M.is_function(v) return v ~= nil and type(v) == 'function' end
function M.is_table(v) return v ~= nil and type(v) == 'table' end

-----------------------------------------------------------------------------
function M.val_number(v, min, max, name)
    local ok = M.is_number(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        return string.format("Invalid number %s: %s", name, tostring(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_integer(v, min, max, name)
    local ok = M.is_integer(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        return string.format("Invalid integer %s: %s", name, tostring(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_string(v, name)
    local ok = M.is_string(v)
    if not ok then
        return string.format("Invalid string %s: %s", name, tostring(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_boolean(v, name)
    local ok = M.is_boolean(v)
    if not ok then
        return string.format("Invalid boolean %s: %s", name, tostring(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_table(v, name)
    local ok = M.is_table(v)
    if not ok then
        return string.format("Invalid table %s", name)
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_function(v, name)
    local ok = M.is_function(v)
    if not ok then
        return string.format("Invalid function %s", name)
    end
    return nil
end

-----------------------------------------------------------------------------
-- Return the module.
return M
