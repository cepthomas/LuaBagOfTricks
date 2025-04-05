--- GP utilities: tables, math, validation, errors, ...
-- Some parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.

local sx = require("stringex")

local M = {}



-----------------------------------------------------------------------------
------------------------------ Fields ---------------------------------------
-----------------------------------------------------------------------------

--------- new ------------
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


-- error (message [, level])
-- Raises an error (see §2.3) with message as the error object. This function never returns.
-- Usually, error adds some information about the error position at the beginning of the message, if the message is a string.
-- The level argument specifies how to get the error position. With level 1 (the default), the error position is where the
-- error function was called. Level 2 points the error to where the function that called error was called; and so on.
-- Passing a level 0 avoids the addition of error position information to the message.

-- warn (msg1, ···)
-- Emits a warning with a message composed by the concatenation of all its arguments (which should be strings).
-- By convention, a one-piece message starting with '@' is intended to be a control message, which is a message to the warning
-- system itself. In particular, the standard warning function in Lua recognizes the control messages "@off", to stop the emission
-- of warnings, and "@on", to (re)start the emission; it ignores unknown control messages. 

-- assert (v [, message])
-- Raises an error if the value of its argument v is false (i.e., nil or false); otherwise, returns all its arguments. In case of error,
-- message is the error object; when absent, it defaults to "assertion failed!"


-- If you are afraid of name clashes when opening a package, you can check the name before the assignment:
function M.open_package (ns)
    for n, v in pairs(ns) do
        if _G[n] ~= nil then
            raise("name clash: " .. n .. " is already defined")
        end
        _G[n] = v
    end
end


-- Use arbitrary lua files. require needs path fixup.
function M.fix_lua_path(s)
    local _, _, dir = ut.get_caller_info(3)
    if not sx.contains(package.path, dir) then -- already there?
        package.path = dir..s..';'..package.path
        -- package.path = './lua/?.lua;./test/lua/?.lua;'..package.path
    end
end


function M.read_all(fn)
    f = io.open(fn, 'r')
    -- f = io.open('docs/music_defs.md', 'w')

    if f ~= nil then
        local s = f:read()
        f:close()
        return s
    else
        error('read file failed: '..fn, 2)
    end
end

function M.write_all(fn, s)
    f = io.open(fn, 'w')

    if f ~= nil then
        local s = f:write(s)
        f:close()
    else
        error('write file failed: '..fn, 2)
    end
end

function M.append(fn, s)
    f = io.open(fn, 'w+')

    if f ~= nil then
        local s = f:write(s)
        f:close()
    else
        error('append file failed: '..fn, 2)
    end

end


--- Create an iterator over a seqence. This captures the Python concept of 'sequence'.
-- For tables, iterates over all values with integer indices.
-- @param seq a sequence; a string (over characters), a table, a file object (over lines) or an iterator function
-- @usage for x in iterate {1,10,22,55} do io.write(x,',') end ==> 1,10,22,55
-- @usage for ch in iterate 'help' do do io.write(ch,' ') end ==> h e l p
function iterate(seq)
    if type(seq) == 'string' then
        local idx = 0
        local n = #seq
        local sub = string.sub
        return function ()
            idx = idx + 1
            if idx > n then return nil
            else
                return sub(seq, idx, idx)
            end
        end
    elseif type(seq) == 'table' then
        local idx = 0
        local n = #seq
        return function()
            idx = idx + 1
            if idx > n then return nil
            else
                return seq[idx]
            end
        end
    elseif type(seq) == 'function' then
        return seq
    elseif type(seq) == 'userdata' and io.type(seq) == 'file' then
        return seq:lines()
    end
end

--- assert that the given argument is in fact of the correct type.
-- @param n argument index
-- @param val the value
-- @param tp the type
-- @param lev optional stack position for trace, default 2
-- @return the validated value
-- @raise if `val` is not the correct type
function M.assert_arg (n, val, tp, lev)
    if type(val) ~= tp then
        error(("argument %d expected a '%s', got a '%s'"):format(n, tp, type(val)), lev or 3)
    end
    return val
end

--- assert that the given argument is in fact of the correct type.
-- @param n argument index
-- @param val the value
-- @param tp the type
-- @param verify an optional verification function
-- @param msg an optional custom message
-- @param lev optional stack position for trace, default 2
-- @return the validated value
-- @raise if `val` is not the correct type
-- @usage
-- local param1 = assert_arg(1,"hello",'table')  --> error: argument 1 expected a 'table', got a 'string'
-- local param4 = assert_arg(4,'!@#$%^&*','string',path.isdir,'not a directory')
--      --> error: argument 4: '!@#$%^&*' not a directory
function M.assert_arg_orig (n, val, tp, verify, msg, lev)
    if type(val) ~= tp then
        error(("argument %d expected a '%s', got a '%s'"):format(n, tp, type(val)), lev or 2)
    end
    if verify and not verify(val) then
        error(("argument %d: '%s' %s"):format(n, val, msg), lev or 2)
    end
    return val
end

-----------------------------------------------------------------------------
------------------------------ pl stuff -------------------------------------
-----------------------------------------------------------------------------


-- temp home for some common stuff.

-- local utils = require 'pl.utils'
-- local math_ceil = math.ceil
-- local assert_arg = utils.assert_arg

-- local _pl = {}


--- is the object of the specified type?
-- If the type is a string, then use type, otherwise compare with metatable
-- @param obj An object to check
-- @param tp String of what type it should be
-- @return boolean
-- @usage utils.is_type("hello world", "string")   --> true
-- -- or check metatable
-- local my_mt = {}
-- local my_obj = setmetatable(my_obj, my_mt)
-- utils.is_type(my_obj, my_mt)  --> true
function M.is_type (obj,tp)
    if type(tp) == 'string' then return type(obj) == tp end
    local mt = getmetatable(obj)
    return tp == mt
end




--- is the object either a function or a callable object?.
-- @param obj Object to check.
function M.is_callable (obj)
    return type(obj) == 'function' or getmetatable(obj) and getmetatable(obj).__call and true
end

-- --- is the object of the specified type?.
-- -- If the type is a string, then use type, otherwise compare with metatable.
-- --
-- -- NOTE: this function is imported from `utils.is_type`.
-- -- @param obj An object to check
-- -- @param tp The expected type
-- -- @function is_type
-- -- @see utils.is_type
-- M.is_type = utils.is_type


-- local fileMT = getmetatable(io.stdout)

-- --- a string representation of a type.
-- -- For tables and userdata with metatables, we assume that the metatable has a `_name`
-- -- field. If the field is not present it will return 'unknown table' or
-- -- 'unknown userdata'.
-- -- Lua file objects return the type 'file'.
-- -- @param obj an object
-- -- @return a string like 'number', 'table', 'file' or 'List'
-- function M.type (obj)
--     local t = type(obj)
--     if t == 'table' or t == 'userdata' then
--         local mt = getmetatable(obj)
--         if mt == fileMT then
--             return 'file'
--         elseif mt == nil then
--             return t
--         else
--             -- TODO: the "unknown" is weird, it should just return the type
--             return mt._name or "unknown "..t
--         end
--     else
--         return t
--     end
-- end

--- is this number an integer?
-- @param x a number
-- @raise error if x is not a number
-- @return boolean
function M.is_integer (x)
    return math_ceil(x)==x
end

--- Check if the object is "empty".
-- An object is considered empty if it is:
-- - `nil`
-- - a table without any items (key-value pairs or indexes)
-- - a string with no content ("")
-- - not a nil/table/string
-- @param o The object to check if it is empty.
-- @param ignore_spaces If the object is a string and this is true the string is
-- considered empty if it only contains spaces.
-- @return `true` if the object is empty, otherwise a falsy value.
function M.is_empty(o, ignore_spaces)
    if o == nil then
        return true
    elseif type(o) == "table" then
        return next(o) == nil
    elseif type(o) == "string" then
        return o == "" or (not not ignore_spaces and (not not o:find("^%s+$")))
    else
        return true
    end
end

local function check_meta (val)
    if type(val) == 'table' then return true end
    return getmetatable(val)
end

--- is an object 'array-like'?
-- An object is array like if:
-- - it is a table, or
-- - it has a metatable with `__len` and `__index` methods
-- NOTE: since `__len` is 5.2+, on 5.1 is usually returns `false` for userdata
-- @param val any value.
-- @return `true` if the object is array-like, otherwise a falsy value.
function M.is_indexable (val)
    local mt = check_meta(val)
    if mt == true then return true end
    return mt and mt.__len and mt.__index and true
end

--- can an object be iterated over with `pairs`?
-- An object is iterable if:
-- - it is a table, or
-- - it has a metatable with a `__pairs` meta method
-- NOTE: since `__pairs` is 5.2+, on 5.1 is usually returns `false` for userdata
-- @param val any value.
-- @return `true` if the object is iterable, otherwise a falsy value.
function M.is_iterable (val)
    local mt = check_meta(val)
    if mt == true then return true end
    return mt and mt.__pairs and true
end

--- can an object accept new key/pair values?
-- An object is iterable if:
-- - it is a table, or
-- - it has a metatable with a `__newindex` meta method
--
-- @param val any value.
-- @return `true` if the object is writeable, otherwise a falsy value.
function M.is_writeable (val)
    local mt = check_meta(val)
    if mt == true then return true end
    return mt and mt.__newindex and true
end

-- -- Strings that should evaluate to true.   -- TODO: add on/off ???
-- local trues = { yes=true, y=true, ["true"]=true, t=true, ["1"]=true }
-- -- Conditions types should evaluate to true.
-- local true_types = {
--     boolean=function(o, true_strs, check_objs) return o end,
--     string=function(o, true_strs, check_objs)
--         o = o:lower()
--         if trues[o] then
--             return true
--         end
--         -- Check alternative user provided strings.
--         for _,v in ipairs(true_strs or {}) do
--             if type(v) == "string" and o == v:lower() then
--                 return true
--             end
--         end
--         return false
--     end,
--     number=function(o, true_strs, check_objs) return o ~= 0 end,
--     table=function(o, true_strs, check_objs) if check_objs and next(o) ~= nil then return true end return false end
-- }

--- Convert to a boolean value.
-- True values are:
--
-- * boolean: true.
-- * string: 'yes', 'y', 'true', 't', '1' or additional strings specified by `true_strs`.
-- * number: Any non-zero value.
-- * table: Is not empty and `check_objs` is true.
-- * everything else: Is not `nil` and `check_objs` is true.
--
-- @param o The object to evaluate.
-- @param[opt] true_strs optional Additional strings that when matched should evaluate to true. Comparison is case insensitive.
-- This should be a List of strings. E.g. "ja" to support German.
-- @param[opt] check_objs True if objects should be evaluated.
-- @return true if the input evaluates to true, otherwise false.
-- function M.to_bool(o, true_strs, check_objs)
--     local true_func
--     if true_strs then
--         assert_arg(2, true_strs, "table")
--     end
--     true_func = true_types[type(o)]
--     if true_func then
--         return true_func(o, true_strs, check_objs)
--     elseif check_objs and o ~= nil then
--         return true
--     end
--     return false
-- end


-----------------------------------------------------------------------------
------------------------------ Application ----------------------------------
-----------------------------------------------------------------------------

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
--- Emulation of C ternary operator. TODOL improve?
-- @param cond to test
-- @param tval if cond is true
-- @param fval if cond is false
-- @return tval or fval
function M.tern(cond, tval, fval)
    if cond then return tval else return fval end
end

-----------------------------------------------------------------------------
--- Checks global space for intruders aka you-forgot-local-again.
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

function M.set_colorize(map)
    _colorize_map = map
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

-----------------------------------------------------------------------------
--- Validate a number value.
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
--- Validate an integer value.
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


-- Return the module.
return M
