--[[
Unit tests for the tester itself.
Run like: lua pnut_runner.lua test_pnut
--]]


-- Create the namespace/module.
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
function M.suite_pnut_basic(pn)
    pn.UT_INFO("Test all UT_xxx() functions")

    pn.UT_INFO("Verify that this info line appears in the report file.")
    pn.UT_ERROR("Verify that this error line appears in the report file.")

    pn.UT_TRUE(2 + 2 == 4) -- pass
    pn.UT_TRUE(2 + 2 == 5) -- fail

    pn.UT_FALSE(2 + 2 == 4) -- fail
    pn.UT_FALSE(2 + 2 == 5) -- pass

    pn.UT_NIL(nil) -- pass
    pn.UT_NIL(2) -- fail

    pn.UT_NOT_NIL(nil) -- fail
    pn.UT_NOT_NIL(2) -- pass

    pn.UT_EQUAL(111, 111) -- pass
    pn.UT_EQUAL(111, 112) -- fail
    pn.UT_EQUAL(111, "111") -- fail

    pn.UT_NOT_EQUAL("ABC", "XYZ") -- pass
    pn.UT_NOT_EQUAL("123", "123") -- fail

    pn.UT_LESS(555, 555.1) -- pass
    pn.UT_LESS(432.01, 432.001) -- fail

    pn.UT_LESS_OR_EQUAL(555, 555.1) -- pass
    pn.UT_LESS_OR_EQUAL(555.1, 555.1) -- pass
    pn.UT_LESS_OR_EQUAL(432.01, 432.001) -- fail

    pn.UT_GREATER(432.01, 432.001) -- pass
    pn.UT_GREATER(555, 555.1) -- fail

    pn.UT_GREATER_OR_EQUAL(555.1, 555) -- pass
    pn.UT_GREATER_OR_EQUAL(555.1, 555.1) -- pass
    pn.UT_GREATER_OR_EQUAL(432.001, 432.01) -- fail

    pn.UT_CLOSE(555.15, 555.16, 0.01) -- pass
    pn.UT_CLOSE(432.02, 432.01, 0.009) -- fail

    -- Check summary. Cache values first.
    suites_run = pn.suites_run
    suites_failed = pn.suites_failed
    cases_run = pn.cases_run
    cases_failed = pn.cases_failed
    pn.UT_EQUAL(suites_run, 2)
    pn.UT_EQUAL(suites_failed, 1)
    pn.UT_EQUAL(cases_run, 36)
    pn.UT_EQUAL(cases_failed, 12)

end

-----------------------------------------------------------------------------
-- Return the module.
return M
