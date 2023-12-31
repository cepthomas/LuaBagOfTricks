--- GP utilities: tables, math, validation, errors, ...

local sx = require("stringex")

local M = {}


---------------------------------------------------------------
--- Execute a file and return the output.
-- @param cmd Command to run.
-- @return Output text.
function M.execute_capture(cmd)
  local f = io.popen(cmd, 'r')
  local s = f:read('*a')
  f:close()
  return s
end

---------------------------------------------------------------
--- If using debugger, bind lua error() function to it. Optional terminal.
-- @param use_dbgr Use debugger.
-- @param use_term Use terminal for debugger.
function M.config_error_handling(use_dbgr, use_term)
    local have_dbgr = false
    local og_error = error -- save original error function

    if use_dbgr then
        have_dbgr, dbg = pcall(require, "debugger")
        if not have_dbgr then
            print(dbg)
        end
    end

    if dbg then 
        -- sub debug handler
        error = dbg.error
    end

    if dbg and use_term then
        dbg.enable_color()
    end

    -- Not using debugger so make a global stub to keep breakpoints from yelling.
    if not dbg then
        function dbg() end
    end

    -- dbg()
end

-----------------------------------------------------------------------------
--- Diagnostic.
-- @param tbl What to dump.
-- @param name Of the tbl.
-- @param indent Nesting.
-- @return string list
function M.dump_table(tbl, name, indent)
    local res = {}
    indent = indent or 0

    if type(tbl) == "table" then
        local sindent = string.rep("    ", indent)
        table.insert(res, sindent .. name .. "(table):")

        -- Do contents.
        indent = indent + 1
        sindent = sindent .. "    "
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                trec = M.dump_table(v, k, indent) -- recursion!
                for _,v in ipairs(trec) do
                    table.insert(res, v)
                end
            else
                table.insert(res, sindent .. k .. ":" .. tostring(v) .. "(" .. type(v) .. ")")
            end
        end
    else
        table.insert(res, "Not a table")
    end

    return res
end

-----------------------------------------------------------------------------
--- Diagnostic.
-- @param tbl What to dump.
-- @param name Of tbl.
-- @return string list
function M.dump_table_string(tbl, name)
    local res = M.dump_table(tbl, name, 0)
    return sx.strjoin('\n', res)
end

-----------------------------------------------------------------------------
--- Gets the file and line of the caller.
-- @param level How deep to look:
--    0 is the getinfo() itself
--    1 is the function that called getinfo() - get_caller_info()
--    2 is the function that called get_caller_info() - usually the one of interest
-- @return { filename, linenumber } or nil if invalid
function M.get_caller_info(level)
    local ret = nil
    local s = debug.getinfo(level, 'S')
    local l = debug.getinfo(level, 'l')
    if s ~= nil and l ~= nil then
        ret = { s.short_src, l.currentline }
    end
    return ret
end

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
    val = math.max(val, min)
    val = math.min(val, max)
    return val
end

-----------------------------------------------------------------------------
--- Ensure integral multiple of resolution, GTE min, LTE max.
-- @param val
-- @param min
-- @param max
-- @param resolution
-- @return
function M.constrain(val, min, max, resolution)
    rval = constrain(val, min, max)
    rval = math.round(rval / resolution) * resolution
    return rval
end

-----------------------------------------------------------------------------
--- Snap to closest neighbor.
-- @param val
-- @param granularity">The neighbors property line.
-- @param round">Round or truncate.
-- @return
function M.clamp(val, granularity, round)
    res = (val / granularity) * granularity
    if round and (val % granularity > granularity / 2) then res = res + granularity end
    return res
end

-----------------------------------------------------------------------------
-- Return the module.
return M
