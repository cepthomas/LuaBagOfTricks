-- GP utilities. Some parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.

local sx = require('stringex')
local lt = require('lbot_types')


-- Module elements.
local M = {}


-----------------------------------------------------------------------------
------------------------------ Global ---------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Replacement for print(...) with file and line added.
function printex(...)
    local res = {}
    local arg = {...}
    local fpath = debug.getinfo(2, 'S').short_src
    local line = debug.getinfo(2, 'l').currentline
    table.insert(res, fpath..'('..line..')')
    for _, v in ipairs(arg) do
        table.insert(res, '['..tostring(v)..']')
    end

    print(sx.strjoin(' ', res))
end


-----------------------------------------------------------------------------
------------------------------ System ---------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Check global space for intruders aka you-forgot-local-again.
-- @param app_glob list of app specific globals
-- @return list of extraneous globals, list of unused globals
function M.check_globals(app_glob)
    lt.val_table(app_glob)
    local extra = {}

    -- Expect to see these normal globals.
    local expected = {'_G', '_VERSION', 'assert', 'collectgarbage', 'coroutine', 'debug', 'dofile', 'error',
        'getmetatable', 'io', 'ipairs', 'load', 'loadfile', 'math', 'next', 'os', 'package', 'pairs', 'pcall',
        'print', 'rawequal', 'rawget', 'rawlen', 'rawset', 'require', 'select', 'setmetatable', 'string',
        'table', 'tonumber', 'tostring', 'type', 'utf8', 'warn', 'xpcall',
        -- standard modules:
        'coroutine', 'debug', 'io', 'math', 'os', 'package', 'string', 'table', 'utf8',
        'arg' }

        for k, v in pairs(expected) do app_glob[k] = v end

    for k, _ in pairs(_G) do
        if expected[k] ~= nil then
            expected[k] = nil -- remove
        else
            table.insert(extra, k)
        end
    end

    return extra, expected
end

-----------------------------------------------------------------------------
-- Add script file path to LUA_PATH. For require.
function M.fix_lua_path(s)
    local _, _, dir = M.get_caller_info(3)
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
    res = math.min(res, max)
    return res
end

-----------------------------------------------------------------------------
--- Snap to closest neighbor.
-- @param val what to snap
-- @param granularity The neighbors property line.
-- @param round Round or truncate.
-- @return snapped value
function M.clamp(val, granularity, round)
    local res = math.floor(val / granularity) * granularity
    if round and (val % granularity > granularity / 2) then res = res + granularity end
    return res
end


-----------------------------------------------------------------------------
------------------------------ Files ----------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- Text file helper.
function M.file_read_all(fn)
    local f = io.open(fn, 'r')

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
    local f = io.open(fn, 'w')

    if f ~= nil then
        f:write(s)
        f:close()
    else
        error('Write file failed: '..fn, 2)
    end
end

-----------------------------------------------------------------------------
--- Text file helper.
function M.file_append_all(fn, s)
    local f = io.open(fn, 'a')

    if f ~= nil then
        f:write(s)
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
-- Text to colorize.
local _colorize_map = {}
-- ANSI colors.
local _colors = { ['red']=91, ['green']=92, ['blue']=94, ['yellow']=33, ['gray']=95, ['bred']=41 }
-- Accessor.
function M.set_colorize(map) _colorize_map = map end

--- ANSI colorize lines of text if phrases are found. Also breaks at newlines.
-- @param text to test
-- @return list of text lines
function M.colorize_text(text)
    -- Split into lines and colorize.
    local res = {}

    local lines = sx.strsplit(text, '\n', false)
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

-----------------------------------------------------------------------------
-- Return the module.
return M
