--- GP utilities: tables, math, validation, errors, ...
-- Some parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.

local sx = require("stringex")

local M = {}



-----------------------------------------------------------------------------
------------------------------ Files ----------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
function M.file_read_all(fn)
    f = io.open(fn, 'r')

    if f ~= nil then
        local s = f:read()
        f:close()
        return s
    else
        error('read file failed: '..fn, 2)
    end
end

-----------------------------------------------------------------------------
function M.file_write_all(fn, s)
    f = io.open(fn, 'w')

    if f ~= nil then
        local s = f:write(s)
        f:close()
    else
        error('write file failed: '..fn, 2)
    end
end

-----------------------------------------------------------------------------
function M.file_append_all(fn, s)
    f = io.open(fn, 'w+')

    if f ~= nil then
        local s = f:write(s)
        f:close()
    else
        error('append file failed: '..fn, 2)
    end

end

-----------------------------------------------------------------------------
------------------------------ Types ----------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- is this number an integer?
-- @param x a number
-- @raise error if x is not a number
-- @return boolean
function M.is_integer(x)
    return math_ceil(x) == x
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
--- Can an object be iterated over with `pairs`?
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
------------------------------ System ---------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--------- TODOL error handling ------------
-- local _err_raise = true
-- -- Similar to Penlight function.
-- -- Use in conjunction with return since it might return nil + error.
-- -- @param msg the string.
-- local function _raise (msg)
--     if _err_raise then
--         error(msg, 2)
--     else
--         return nil, msg
--     end
-- end
-- -- this put in _G
-- raise = _raise


-----------------------------------------------------------------------------
-- TODOL If you are afraid of name clashes when opening a package, you can check the name before the assignment.
function M.check_open_package (name) -->> check_global_name?
    for n, v in pairs(name) do
        if _G[n] ~= nil then
            error("name clash: " .. n .. " is already defined")
        end
        _G[n] = v
    end
end

-----------------------------------------------------------------------------
--- TODOL Checks global space for intruders aka you-forgot-local-again.
-- @param app_exp list of app specific globals
-- @return list of extraneous globals, list of missing expected
function M.check_globals(app_exp)
    -- Make copies as we destroy the tables - residual is considered missing.
    local app_exp_c = M.copy(app_exp)

    -- Expect to see these.
    local sys_exp_c = {'_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'dofile', 'error',
        'getmetatable', 'io', 'ipairs', 'load', 'loadfile', 'math', 'next', 'os', 'package', 'pairs', 'pcall',
        'print', 'rawequal', 'rawget', 'rawlen', 'rawset', 'require', 'select', 'setmetatable', 'string',
        'table', 'tonumber', 'tostring', 'type', 'utf8', 'warn', 'xpcall' }

    local extra = {}

    local global_names = M.keys(_G)

    for _, v in ipairs(global_names) do
        local ind = M.contains(sys_exp_c, v)
        if ind ~= nil then
            table.remove(sys_exp_c, ind)
        end

        if ind == nil then
            ind = M.contains(app_exp_c, v)
            if ind ~= nil then
                table.remove(app_exp_c, ind)
            end
        end

        if ind == nil then
            table.insert(extra, v)
        end
    end

    return extra, app_exp_c
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
--- If using debugger, bind lua error() function to it.
-- @param use_dbgr Use debugger.
function M.config_debug(use_dbgr)
    local have_dbgr = false
    local orig_error = error -- save original error function
    local use_term = true -- Use terminal for debugger.

    if use_dbgr then
        have_dbgr, dbg = pcall(require, "debugger")
    end

    if dbg then
        -- sub debug handler
        error = dbg.error
        if use_term then
            dbg.enable_color()
            dbg.auto_where = 3
        end
    else
        -- Not using debugger so make global stubs to keep breakpoints from yelling.
        dbg =
        {
            error = function(error, level) end,
            assert = function(error, message) end,
            call = function(f, ...) end,
        }
        setmetatable(dbg, { __call = function(self) end })
    end
end


-----------------------------------------------------------------------------
--- Gets the file and line of the caller.
-- @param level How deep to look:
--    0 is the getinfo() itself
--    1 is the function that called getinfo() - get_caller_info()
--    2 is the function that called get_caller_info() - usually the one of interest
-- @return filename, linenumber, directory - may be nil
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
------------------------- Value checking ------------------------------------
-----------------------------------------------------------------------------

-- assert (v [, message])
-- Raises an error if the value of its argument v is false (i.e., nil or false); otherwise, returns all its arguments. In case of error,
-- message is the error object; when absent, it defaults to "assertion failed!"

-----------------------------------------------------------------------------
--- Assert that the given argument is the correct type - raises error()
-- @param n argument index
-- @param val the value
-- @param tp the type
-- @param lev optional stack position for trace, default 3
-- @return the validated value
function M.assert_arg (n, val, tp, lev)
    if type(val) ~= tp then
        error(("argument %d expected a '%s', got a '%s'"):format(n, tp, type(val)), lev or 3)
    end
    return val
end

-----------------------------------------------------------------------------
--- Validate a number value - return T/F.
-- @param v which value
-- @param min range inclusive - nil means no limit
-- @param max range inclusive - nil means no limit
-- @return return true if correct type and in range.
function M.val_number(v, min, max)
    local ok = v ~= nil and type(v) == 'number'
    if ok and max ~= nil then ok = ok and v <= max end
    if ok and min ~= nil then ok = ok and v >= min end
    return ok
end

-----------------------------------------------------------------------------
--- Validate an integer value - return T/F.
-- @param v which value
-- @param min range inclusive - nil means no limit
-- @param max range inclusive - nil means no limit
-- @return return true if correct type and in range.
function M.val_integer(v, min, max)
    local ok = v ~= nil and math.type(v) == 'integer'
    if ok and max ~= nil then ok = ok and v <= max end
    if ok and min ~= nil then ok = ok and v >= min end
    return ok
end


-----------------------------------------------------------------------------
------------------------------ TODOL homes ---------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Emulation of C ternary operator. TODOL improve?
-- @param cond to test
-- @param tval if cond is true
-- @param fval if cond is false
-- @return tval or fval
function M.tern(cond, tval, fval)
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
-- Return the module.
return M
