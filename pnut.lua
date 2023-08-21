--[[
Core module for executing the test suites themselves. Has all the assert functions.
--]]

local ut = require("utils")

-- Create the namespace/module.
local M = {}

-- Create an execution context.
M.suites_run = 0
M.suites_failed = 0
M.cases_run = 0
M.cases_failed = 0
M.result_text = {}
-- M.result_format = "readable" -- "xml"  TODO2

-- Current states.
local curr_suite_pass = true



-----------------------------------------------------------------------------
-- General msg output to file and log.
-- @param msg The info to write.
local function write_line(msg)
    table.insert(M.result_text, msg)
end

-----------------------------------------------------------------------------
-- Error msg output to file and log.
-- @param msg The info to write.
local function write_error(msg)
    write_line("! " .. msg)
end

-- -----------------------------------------------------------------------------
-- --- Gets the file and line of the test script.
-- local function get_caller_info()
--     return string.format("%s(%s)", debug.getinfo(4, 'S').source, debug.getinfo(4, 'l').currentline)
-- end

-----------------------------------------------------------------------------
-- A case has failed so update all states and counts.
-- @param msg message.
local function case_failed(msg)
    -- Update the states and counts.
    if curr_suite_pass then
        curr_suite_pass = false
        M.suites_failed = M.suites_failed + 1
    end

    M.cases_failed = M.cases_failed + 1

    -- Print failure information.
    caller = ut.get_caller_info(4)
    write_error(caller[1] .. "(" .. caller[2] .. "): " .. msg)
end

-----------------------------------------------------------------------------
-- Start a new suite.
-- @param desc Free text.
function M.do_suite(desc)
    write_line("\nRunning Suite: " .. desc)
    write_line("-----------------------------------------------------------")

    -- Reset the current p/f states.
    curr_suite_pass = true
    curr_case_pass = true

    M.suites_run = M.suites_run + 1
end

-----------------------------------------------------------------------------
-- Add a general comment line to the report.
-- @param info free text.
function M.UT_INFO(info)
    write_line(info)
end

-----------------------------------------------------------------------------
-- Add an error comment line to the report.
-- @param info free text.
function M.UT_ERROR(info)
    write_error(info)
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not true.
-- @param expr Boolean expression.
function M.UT_TRUE(expr)
    M.cases_run = M.cases_run + 1
    if expr == false then
        case_failed("Expression is not true")
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not true.
-- @param expr Boolean expression.
function M.UT_FALSE(expr)
    M.cases_run = M.cases_run + 1
    if expr == true then
        case_failed("Expression is not false")
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not true.
-- @param expr Boolean expression.
function M.UT_NOT_NIL(expr)
    M.cases_run = M.cases_run + 1
    if expr == nil then
        case_failed("Expression is nil")
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not true.
-- @param expr Boolean expression.
function M.UT_NIL(expr)
    M.cases_run = M.cases_run + 1
    if expr ~= nil then
        case_failed("Expression is not nil")
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not equal.
-- @param val1 First value.
-- @param val2 Second value.
function M.UT_EQUAL(val1, val2)
    M.cases_run = M.cases_run + 1
    if val1 ~= val2 then
        case_failed(tostring(val1) .. " is not equal to " .. tostring(val2))
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if equal.
-- @param val1 First value.
-- @param val2 Second value.
function M.UT_NOT_EQUAL(val1, val2)
    M.cases_run = M.cases_run + 1
    if val1 == val2 then
        case_failed(tostring(val1) .. " is equal to " .. tostring(val2))
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not less than.
-- @param val1 First value.
-- @param val2 Second value.
function M.UT_LESS(val1, val2)
    M.cases_run = M.cases_run + 1
    if not(val1 < val2) then
        case_failed(tostring(val1) .. " is not less than " .. tostring(val2))
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not less than or equal.
-- @param val1 First value.
-- @param val2 Second value.
function M.UT_LESS_OR_EQUAL(val1, val2)
    M.cases_run = M.cases_run + 1
    if not(val1 <= val2) then
        case_failed(tostring(val1) .. " is not less than or equal to " .. tostring(val2))
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not greater than.
-- @param val1 First value.
-- @param val2 Second value.
function M.UT_GREATER(val1, val2)
    M.cases_run = M.cases_run + 1
    if not(val1 > val2) then
        case_failed(tostring(val1) .. " is not greater than " .. tostring(val2))
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not greater than or equal.
-- @param val1 First value.
-- @param val2 Second value.
function M.UT_GREATER_OR_EQUAL(val1, val2)
    M.cases_run = M.cases_run + 1
    if not(val1 >= val2) then
        case_failed(tostring(val1) .. " is not greater than or equal to " .. tostring(val2))
    end
end

-----------------------------------------------------------------------------
-- Tests expression and registers a failure if not close to each other.
-- @param val1 First value.
-- @param val2 Second value.
-- @param tol Within tolerance.
function M.UT_CLOSE(val1, val2, tol)
    M.cases_run = M.cases_run + 1
    if math.abs(val1 - val2) > tol then
        case_failed(tostring(val1) .. " is not close to " .. tostring(val2))
    end
end

-----------------------------------------------------------------------------
-- Return the module.
return M
