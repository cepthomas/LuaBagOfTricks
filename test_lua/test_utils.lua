-- TODO2 Unit tests for the utils. also validators?

local sx = require("stringex")
local ut = require("utils")

local M = {}

-----------------------------------------------------------------------------
function M.setup(pn)
    -- pn.UT_INFO("setup()!!!")
end

-----------------------------------------------------------------------------
function M.teardown(pn)
    -- pn.UT_INFO("teardown()!!!")
end

-----------------------------------------------------------------------------
function M.suite_utils(pn)

    -- Test dump_table().
    tt = { aa="pt1", bb=90901, alist={"qwerty", 777, temb1={ jj="pt8", b=true, temb2={ num=1.517, dd="strdd" } }, intx=5432}}
    s = ut.dump_table_string(tt, true)
    pn.UT_EQUAL(#s, 310)

--[[
--- Execute a file and return the output.
-- @param cmd Command to run.
-- @return Output text.
function M.execute_and_capture(cmd)

--- Diagnostic.
-- @param tbl What to dump.
-- @param name Of the tbl.
-- @param indent Nesting.
-- @return string list
function M.dump_table(tbl, name, indent)

--- Diagnostic.
-- @param tbl What to dump.
-- @param name Of tbl.
-- @return string
function M.dump_table_string(tbl, true, name)

--- Gets the file and line of the caller.
function M.get_caller_info(level)

function M.is_integer(v) return M.to_integer(v) ~= nil end

function M.is_number(v) return v ~= nil and type(v) == 'number' end

function M.is_string(v) return v ~= nil and type(v) == 'string' end

function M.is_boolean(v) return v ~= nil and type(v) == 'boolean' end

function M.is_function(v) return v ~= nil and type(v) == 'function' end

function M.is_table(v) return v ~= nil and type(v) == 'table' end

--- Convert value to integer.
-- @param v value to convert
-- @return integer or nil if not convertible
function M.to_integer(v)

--- Like tostring() without address info. Mainly for unit testing.
-- @param v value to convert
-- @return string
function M.tostring_cln(v)

--- Remap a value to new coordinates.
-- @param val
-- @param start1
-- @param stop1
-- @param start2
-- @param stop2
-- @return
function M.map(val, start1, stop1, start2, stop2)

--- Bounds limits a value.
-- @param val
-- @param min
-- @param max
-- @return
function M.constrain(val, min, max)

--- Ensure integral multiple of resolution, GTE min, LTE max.
-- @param val
-- @param min
-- @param max
-- @param resolution
-- @return
function M.constrain(val, min, max, resolution)

--- Snap to closest neighbor.
-- @param val
-- @param granularity">The neighbors property line.
-- @param round">Round or truncate.
-- @return
function M.clamp(val, granularity, round)

]]

end


-----------------------------------------------------------------------------
-- Return the module.
return M
