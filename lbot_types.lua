-- LBOT type support. Some parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.

local M = {}


-----------------------------------------------------------------------------
--- Is this number an integer?
-- @param v a number
-- @return boolean
function M.is_integer(v)
    return math.type(v) == "integer"
end

-----------------------------------------------------------------------------
--- Convert value to integer.
-- @param v value to convert
-- @return integer or nil if not convertible.
function M.tointeger(v)
    if math.type(v) == "integer" then return v
    elseif type(v) == "string" then return tonumber(v, 10)
    else return nil
    end
end

-----------------------------------------------------------------------------
--- Is the object either a function or a callable object?.
-- @param obj what to check
-- @return T/F
function M.is_callable(obj)
    return (type(obj) == 'function') or (getmetatable(obj) ~= nil and getmetatable(obj).__call ~= nil) and true
end

-----------------------------------------------------------------------------
--- Is an object a sequence?
-- @param obj what to check
-- @return T/F
function M.is_indexable(obj)
    return (type(obj) == 'table') or (getmetatable(obj) ~= nil and getmetatable(obj).__len ~= nil and getmetatable(obj).__index ~= nil) -- and true
end

-----------------------------------------------------------------------------
--- Can an object be iterated over with pairs?
-- @param obj what to check
-- @return T/F
function M.is_iterable(obj)
    return (type(obj) == 'table') or (getmetatable(obj) ~= nil and getmetatable(obj).__pairs ~= nil) -- and true
end

-----------------------------------------------------------------------------
--- Can an object accept new key/pair values?
-- @param obj any value.
-- @return T/F
function M.is_writeable(obj)
    return (type(obj) == 'table') or (getmetatable(obj) ~= nil and getmetatable(obj).__newindex ~= nil) -- and true
end

-----------------------------------------------------------------------------
--- Validate a value type.
-- @param v which value
-- @param vt expected type
function M.val_type(v, vt)
    if vt == 'integer' and M.is_integer(v) then return true end
    local ok = type(v) == vt
    if not ok then error('Invalid type:'..type(v)) end
end

-----------------------------------------------------------------------------
--- Validate a number value.
-- @param v which value
-- @param min range inclusive, nil means no limit
-- @param max range inclusive, nil means no limit
function M.val_number(v, min, max)
    local ok = v ~= nil and type(v) == 'number'
    if ok and max ~= nil then ok = ok and v <= max end
    if ok and min ~= nil then ok = ok and v >= min end
    if not ok then error('Invalid number:'..tostring(v)) end
end

-----------------------------------------------------------------------------
--- Validate an integer value.
-- @param v which value
-- @param min range inclusive, nil means no limit
-- @param max range inclusive, nil means no limit
function M.val_integer(v, min, max)
    local ok = v ~= nil and math.type(v) == 'integer'
    if ok and max ~= nil then ok = ok and v <= max end
    if ok and min ~= nil then ok = ok and v >= min end
    if not ok then error('Invalid integer:'..tostring(v)) end
end

-----------------------------------------------------------------------------
--- Validate a function value.
-- @param f which function
function M.val_function(f)
    if f == nil or type(f) ~= 'function' then error('Invalid function:'..tostring(f)) end
end

-----------------------------------------------------------------------------
--- Validate a function value.
-- @param s which
function M.val_string(s)
    if s == nil or type(s) ~= 'string' then error('Invalid string:'..tostring(s)) end
end

-----------------------------------------------------------------------------
--- Validate a table type.
-- @param t the table
-- @param min_size optional check
function M.val_table(t, min_size)
    if t == nil or type(t) ~= 'table' then error('Not a valid table') end
    min_size = min_size or 0
    local num = 0
    for _, _ in pairs(t) do num = num + 1 end
    if num < min_size then error('Not min size: '..tostring(min_size)) end
end

-----------------------------------------------------------------------------
--- Validate a table sequence type.
-- @param t the table
function M.val_sequence(t)
    M.val_table(t)

    local tnum = 0 -- total count
    for _, _ in pairs(t) do tnum = tnum + 1 end
    if tnum ~= #t then error('Not sequence type') end

    -- local ind = 1
    -- for i, _ in ipairs(t) do
    --     if i ~= ind then error('Non-consecutive indexes') end
    --     ind = ind + 1
    -- end
end

-----------------------------------------------------------------------------
--- Check nilness.
-- @param v which value
function M.val_not_nil(v)
    if v == nil then error('Value is nil') end
end

-----------------------------------------------------------------------------
--- Validate a function type.
-- @param func a function or callable object
function M.val_func(func)
    local ok = M.is_callable(func)
    if not ok then error('Invalid function:'..type(func)) end
end

-----------------------------------------------------------------------------
-- Return the module.
return M
