-- Unit tests for the tester itself.


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
function M.suite_basic(pn)
    pn.UT_INFO("Test all UT_XXX() functions. Verification is by inspection of the report file.")

    pn.UT_INFO("Verify that this info line appears in the report file. There should be 3 Infos: 2, 3, 5.")
    pn.UT_ERROR("Verify that this error line appears in the report file.")

    pn.UT_TRUE(2 + 2 == 4, ">>> Info 1.") -- pass
    pn.UT_TRUE(2 + 2 == 5, "should fail") -- fail

    pn.UT_FALSE(2 + 2 == 4, "should fail") -- fail
    pn.UT_FALSE(2 + 2 == 5) -- pass

    pn.UT_NIL(nil) -- pass
    pn.UT_NIL(2, "should fail") -- fail

    pn.UT_NOT_NIL(nil, "should fail") -- fail
    pn.UT_NOT_NIL(2) -- pass

    pn.UT_EQUAL(111, 111) -- pass
    pn.UT_EQUAL(111, 112, "should fail") -- fail
    pn.UT_EQUAL(111, "111", "should fail") -- fail
    pn.UT_NOT_EQUAL("ABC", "XYZ") -- pass
    pn.UT_NOT_EQUAL("123", "123", "should fail") -- fail

    pn.UT_STR_EQUAL("111", "111") -- pass
    pn.UT_STR_NOT_EQUAL("111", 111, "should fail") -- fail
    pn.UT_STR_NOT_EQUAL(111, "111", "should fail") -- fail
    pn.UT_STR_NOT_EQUAL("222", "111", "should fail") -- fail

    pn.UT_LESS(555, 555.1) -- pass
    pn.UT_LESS(432.01, 432.001, "should fail") -- fail

    pn.UT_LESS_OR_EQUAL(555, 555.1) -- pass
    pn.UT_LESS_OR_EQUAL(555.1, 555.1) -- pass
    pn.UT_LESS_OR_EQUAL(432.01, 432.001, "should fail") -- fail

    pn.UT_GREATER(432.01, 432.001, ">>> Info 4.") -- pass
    pn.UT_GREATER(555, 555.1, "should fail") -- fail

    pn.UT_GREATER_OR_EQUAL(555.1, 555) -- pass
    pn.UT_GREATER_OR_EQUAL(555.1, 555.1) -- pass
    pn.UT_GREATER_OR_EQUAL(432.001, 432.01, "should fail") -- fail

    pn.UT_CLOSE(555.15, 555.16, 0.01) -- pass
    pn.UT_CLOSE(432.02, 432.01, 0.009, "should fail") -- fail

    -- Return status.
    local stat = pn.UT_NOT_NIL(nil, "should fail") -- fail
    pn.UT_TRUE(stat, ">>> You should see me!!!")

    stat = pn.UT_NIL(nil) -- pass
    pn.UT_TRUE(stat, "should fail")

    -- Check summary. Cache values first.
    num_suites_run = pn.num_suites_run
    num_suites_failed = pn.num_suites_failed
    num_cases_run = pn.num_cases_run
    num_cases_failed = pn.num_cases_failed
    pn.UT_EQUAL(num_suites_run, 1)
    pn.UT_EQUAL(num_suites_failed, 1, ">>> Info 6.")
    pn.UT_EQUAL(num_cases_run, 33)
    pn.UT_EQUAL(num_cases_failed, 16)

end

-----------------------------------------------------------------------------
-- Return the module.
return M
