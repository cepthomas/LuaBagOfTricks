--- GP utilities: tables, math, validation, errors, ...
-- Some parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.

local sx = require("stringex")

local M = {}


-----------------------------------------------------------------------------
------------------------------ System ---------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Check global space for intruders aka you-forgot-local-again.
-- @param app_glob list of app specific globals
-- @return list of extraneous globals, list of unused globals
function M.check_globals(app_glob)
    M.val_table(app_glob, 0)
    local extra = {}

    -- Expect to see these normal globals.
    local exp = {'_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'dofile', 'error',
        'getmetatable', 'io', 'ipairs', 'load', 'loadfile', 'math', 'next', 'os', 'package', 'pairs', 'pcall',
        'print', 'rawequal', 'rawget', 'rawlen', 'rawset', 'require', 'select', 'setmetatable', 'string',
        'table', 'tonumber', 'tostring', 'type', 'utf8', 'warn', 'xpcall',
        -- standard modules:
        'coroutine', 'debug', 'io', 'math', 'os', 'package', 'string', 'table', 'utf8' }
    exp:add_range(app_glob)    

    for _, v in ipairs(_G) do
        if exp:contains(v) then
            exp:remove(v)
        else
            extra:add(v)
        end
    end

    return extra, exp
end

-----------------------------------------------------------------------------
-- Add script file path to LUA_PATH. For require.
function M.fix_lua_path(s)
    local _, _, dir = ut.get_caller_info(3)
    if not sx.contains(package.path, dir) then -- already there?
        package.path = dir..s..';'..package.path
        -- package.path = './lua/?.lua;./test/lua/?.lua;'..package.path
    end
end

-----------------------------------------------------------------------------
--- Execute a file and return the output.
-- @param cmd Command to run.
-- @return Output text or nil if invalid file.
function M.execute_and_capture(cmd)
    local f = io.popen(cmd, 'r')
    if f ~= nil then
        local s = f:read('*a')
        f:close()
        return s
    else
        return nil
    end
end

-----------------------------------------------------------------------------
--- Gets the file and line of the caller.
-- @param level How deep to look:
--    0 is the debug.getinfo() itself
--    1 is the function that called debug.getinfo() - this function
--    2 is the function that called this function - usually the one of interest
--    3 is 2's caller
--    etc...
-- @return filepath, linenumber, directory - may be nil
function M.get_caller_info(level)
    local fpath = debug.getinfo(level, 'S').short_src
    local line = debug.getinfo(level, 'l').currentline
    -- dir is a bit more work
    local sep = package.config:sub(1,1)
    local parts = sx.strsplit(fpath, sep)
    table.remove(parts, #parts)
    local dir = sx.strjoin(sep, parts)

    return fpath, line, dir
end


-----------------------------------------------------------------------------
------------------------- Types ---------------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Checks if a table is a pure array.
-- @param t the table
-- @return T/F, value data type if homogenous - nil otherwise
function M.is_array(t)
    local val_type = nil
    local ok = t ~= nil and type(t) == 'table'
    local num = 0

    if ok then
        -- Check if all keys are indexes.
        for k, v in pairs(t) do
            if type(k) ~= 'number' then ok = false end
            num = num + 1
        end
    end

    if ok then
        -- Check sequential from 1.
        for i = 1, num do
            if t[i] == nil then ok = false end

            if i == 1 then val_type = type(t[i])
            elseif type(t[i]) ~= val_type then val_type = nil
            end
        end
    end

    return ok, val_type
end

-----------------------------------------------------------------------------
--- Is this number an integer?
-- @param x a number
-- @raise error if x is not a number
-- @return boolean
function M.is_integer(x)
    return math.type(v) == "integer"
end

-----------------------------------------------------------------------------
--- Convert value to integer.
-- @param v value to convert
-- @return integer or nil if not convertible.
function M.tointeger(v)
    -- if type(v) == "number" and math.ceil(v) == v then return v
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
    return (type(obj) == 'function') or (getmetatable(obj) ~= nil and getmetatable(obj).__call ~= nil) -- and true
end

-----------------------------------------------------------------------------
--- Is an object 'array-like'?
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
------------------------- Validation ----------------------------------------
-----------------------------------------------------------------------------

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
--- Validate a value type.
-- @param v which value
-- @param vt expected type
function M.val_type(v, vt)
    local ok = type(v) == vt
    if not ok then error('Invalid type:'..type(v)) end
end

-----------------------------------------------------------------------------
--- Validate a tabnle type.
-- @param t the table
-- @param min_size optional check
function M.val_table(t, min_size)
    local ok = t ~= nil and type(t) == 'table'
    if ok and min_size ~= nil then ok = ok and #t >= min_size end
    if not ok then error('Invalid table:'..tostring(min_size)) end
end

-----------------------------------------------------------------------------
--- Check nilness.
-- @param v which value
function M.val_not_nil(v)
    local ok = v ~= nil
    if not ok then error('Value is nil') end
end

-----------------------------------------------------------------------------
--- Validate a function type.
-- @param func a function or callable object
function M.val_func(func)
    local ok = M.is_callable(func)
    if not ok then error('Invalid function:'..type(func)) end
end


-----------------------------------------------------------------------------
------------------------- Math ----------------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Remap a value to new coordinates.
-- @param val
-- @param start1
-- @param stop1
-- @param start2
-- @param stop2
-- @return
function M.map(val, start1, stop1, start2, stop2)
    return start2 + (stop2 - start2) * (val - start1) / (stop1 - start1)
end

-----------------------------------------------------------------------------
--- Bounds limits a value.
-- @param val
-- @param min
-- @param max
-- @return
function M.constrain(val, min, max)
    local res = math.max(val, min)
    res = math.min(val, max)
    return res
end

-----------------------------------------------------------------------------
--- Snap to closest neighbor.
-- @param val what to snap
-- @param granularity The neighbors property line.
-- @param round Round or truncate.
-- @return snapped value
function M.clamp(val, granularity, round)
    local res = (val / granularity) * granularity
    if round and (val % granularity > granularity / 2) then res = res + granularity end
    return res
end


-----------------------------------------------------------------------------
------------------------------ Files ----------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Text file helper.
function M.file_read_all(fn)
    f = io.open(fn, 'r')

    if f ~= nil then
        local s = f:read()
        f:close()
        return s
    else
        error('Read file failed: '..fn, 2)
    end
end

-----------------------------------------------------------------------------
--- Text file helper.
function M.file_write_all(fn, s)
    f = io.open(fn, 'w')

    if f ~= nil then
        local s = f:write(s)
        f:close()
    else
        error('Write file failed: '..fn, 2)
    end
end

-----------------------------------------------------------------------------
--- Text file helper.
function M.file_append_all(fn, s)
    f = io.open(fn, 'w+')

    if f ~= nil then
        local s = f:write(s)
        f:close()
    else
        error('Append file failed: '..fn, 2)
    end
end


-----------------------------------------------------------------------------
------------------------------ Odds and Ends --------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Emulation of C ternary operator.
-- @param cond to test
-- @param tval if cond is true
-- @param fval if cond is false
-- @return tval or fval
function M.ternary(cond, tval, fval)
    if cond then return tval else return fval end
end

-----------------------------------------------------------------------------
--- ANSI colorize lines of text if phrases are found. Also breaks at newlines.
-- @param text to test
-- @return list of text lines
function M.colorize_text(text)
    -- Split into lines and colorize.
    local res = {}

    lines = sx.strsplit(text, '\n', false)
    for _, l in ipairs(lines) do
        local s = l -- default
        for k, v in pairs(_colorize_map) do
            if sx.contains(l, k) then
                local col = _colors[v]
                if col == nil then error('Invalid color for phrase '..k) end
                s = string.char(27)..'['..col..'m'..l..string.char(27)..'[0m'
            end
        end
        table.insert(res, s)
    end
    return res
end

-- Text to colorize.
local _colorize_map = {}
-- ANSI colors.
local _colors = { ['red']=91, ['green']=92, ['blue']=94, ['yellow']=33, ['gray']=95, ['bred']=41 }
-- Accessor.
function M.set_colorize(map) _colorize_map = map end


-----------------------------------------------------------------------------
-- Return the module.
return M
