-- GP utilities for validation.

local sx = require("stringex")
local ut = require('utils')

local M = {}



-----------------------------------------------------------------------------
function M.val_number(v, min, max, name)
    local ok = ut.is_number(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        return string.format("Invalid number %s: %s", name, ut.tostringcln(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_integer(v, min, max, name)
    local ok = ut.is_integer(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        return string.format("Invalid integer %s: %s", name, ut.tostringcln(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_string(v, name)
    local ok = ut.is_string(v)
    if not ok then
        return string.format("Invalid string %s: %s", name, ut.tostringcln(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_boolean(v, name)
    local ok = ut.is_boolean(v)
    if not ok then
        return string.format("Invalid boolean %s: %s", name, ut.tostringcln(v))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_table(v, name)
    local ok = ut.is_table(v)
    if not ok then
        return string.format("Invalid table %s", ut.tostringcln(name))
    end
    return nil
end

-----------------------------------------------------------------------------
function M.val_function(v, name)
    local ok = ut.is_function(v)
    if not ok then
        return string.format("Invalid function %s", ut.tostringcln(name))
    end
    return nil
end

-----------------------------------------------------------------------------
-- Return the module.
return M
