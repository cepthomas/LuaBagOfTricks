--[[
GP error utilities. TODO0 prune, consolidate, incorporate debugger.lua, ...
--]]


-- Create the namespace/module.
local M = {}


-- local dbg = require("debugger")
-- local have_dbg = true
-- -- or
-- -- local have_dbg, dbg = pcall(require, "debugger") -- TODO0 cleaner way
-- -- if not have_dbg then
-- --     print("You are not using debugger module!")
-- -- end
-- local function _error(msg, usage)
--     if usage ~= nil then msg = msg .. "\n" .. "Usage: interop.lua -ch|md|cs your_spec.lua your_outfile" end
--     -- if have_dbg then dbg.error(msg) else error(msg) end
--     -- dbg()
--     print(">>>>>>>> error(msg)")--..msg)
--     error(msg)
-- end






-----------------------------------------------------------------------------
function M.is_integer(v) return math.ceil(v) == v end
function M.is_number(v) return type(v) == 'number' end
function M.is_string(v) return type(v) == 'string' end
function M.is_boolean(v) return type(v) == 'boolean' end
function M.is_function(v) return type(v) == 'function' end
function M.is_table(v) return type(v) == 'table' end

-----------------------------------------------------------------------------
function M.do_error(s, level)

    error(s, level) -- TODO0 Add some options or config?

    -- error (message [, level])
    -- Raises an error (see §2.3) with message as the error object. This function never returns.
    -- Usually, error adds some information about the error position at the beginning of the message, if the message is a string. 
    -- The level argument specifies how to get the error position. With level 1 (the default), the error position is where the 
    -- error function was called. Level 2 points the error to where the function that called error was called; and so on. 
    -- Passing a level 0 avoids the addition of error position information to the message.

    -- warn (msg1, ···)
    -- Emits a warning with a message composed by the concatenation of all its arguments (which should be strings).
    -- By convention, a one-piece message starting with '@' is intended to be a control message, which is a message to 
    -- the warning system itself. In particular, the standard warning function in Lua recognizes the control messages "@off", 
    -- to stop the emission of warnings, and "@on", to (re)start the emission; it ignores unknown control messages.

end

-----------------------------------------------------------------------------
function M.chk_number(v, max, min)
    local ok = M.is_number(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        local s = string.format("Invalid number:%s", tostring(v))
        M.do_error(s, 3) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.chk_integer(v, max, min)
    local ok = M.is_integer(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        local s = string.format("Invalid integer:%s", tostring(v))
        M.do_error(s, 3) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.chk_string(v)
    local ok = M.is_string(v)
    if not ok then
        local s = string.format("Invalid string:%s", tostring(v))
        M.do_error(s, 3) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.chk_boolean(v)
    local ok = M.is_boolean(v)
    if not ok then
        local s = string.format("Invalid boolean:%s", tostring(v))
        M.do_error(s, 3) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.chk_table(v)
    local ok = M.is_table(v)
    if not ok then
        local s = string.format("Invalid table:%s", tostring(v))
        M.do_error(s, 3) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.chk_function(v)
    local ok = M.is_function(v)
    if not ok then
        local s = string.format("Invalid function:%s", tostring(v))
        M.do_error(s, 3) -- who called me
    end
end

-----------------------------------------------------------------------------
-- Return the module.
return M
