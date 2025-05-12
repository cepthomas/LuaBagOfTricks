-- Unit tests for the tester itself.


local M = {}

-- -----------------------------------------------------------------------------
-- function M.setup(pn)
--     -- pn.UT_INFO("setup()!!!")
-- end

-- -----------------------------------------------------------------------------
-- function M.teardown(pn)
--     -- pn.UT_INFO("teardown()!!!")
-- end

-----------------------------------------------------------------------------
function M.suite_basic(pn)
    local PASS_STR = "!!! Pass => should not be in report" -- 16
    local FAIL_STR = "Fail => should be in report" -- 16

    pn.UT_INFO("Test all UT_XXX() functions. Verification is by inspection of the report file.")

    pn.UT_TRUE(2 + 2 == 4, PASS_STR)
    pn.UT_TRUE(2 + 2 == 5, FAIL_STR)

    pn.UT_FALSE(2 + 2 == 4, FAIL_STR)
    pn.UT_FALSE(2 + 2 == 5, PASS_STR)

    pn.UT_NIL(nil, PASS_STR)
    pn.UT_NIL(2, FAIL_STR)

    pn.UT_NOT_NIL(nil, FAIL_STR)
    pn.UT_NOT_NIL(2, PASS_STR)

    pn.UT_EQUAL(111, 111, PASS_STR)
    pn.UT_EQUAL(111, 112, FAIL_STR)
    pn.UT_EQUAL(111, "111", FAIL_STR)
    pn.UT_NOT_EQUAL("ABC", "XYZ", PASS_STR)
    pn.UT_NOT_EQUAL("123", "123", FAIL_STR)

    pn.UT_STR_EQUAL("111", "111", PASS_STR)
    pn.UT_STR_NOT_EQUAL("111", 111, FAIL_STR)
    pn.UT_STR_NOT_EQUAL(111, "111", FAIL_STR)
    pn.UT_STR_NOT_EQUAL("222", "111", PASS_STR)

    pn.UT_LESS(555, 555.1, PASS_STR)
    pn.UT_LESS(432.01, 432.001, FAIL_STR)

    pn.UT_LESS_OR_EQUAL(555, 555.1, PASS_STR)
    pn.UT_LESS_OR_EQUAL(555.1, 555.1, PASS_STR)
    pn.UT_LESS_OR_EQUAL(432.01, 432.001, FAIL_STR)

    pn.UT_GREATER(432.01, 432.001, PASS_STR)
    pn.UT_GREATER(555, 555.1, FAIL_STR)

    pn.UT_GREATER_OR_EQUAL(555.1, 555, PASS_STR)
    pn.UT_GREATER_OR_EQUAL(555.1, 555.1, PASS_STR)
    pn.UT_GREATER_OR_EQUAL(432.001, 432.01, FAIL_STR)

    pn.UT_CLOSE(555.15, 555.16, 0.01)
    pn.UT_CLOSE(432.02, 432.01, 0.009, FAIL_STR)

    -- Return status.
    local stat = pn.UT_NOT_NIL(nil, FAIL_STR)
    pn.UT_FALSE(stat, PASS_STR)

    stat = pn.UT_NIL(nil)
    pn.UT_TRUE(stat, PASS_STR)

    -- UT_RAISES
    local function func_that_throws(sum, a1, a2, a3)
        if a1 + a2 + a3 ~= sum then error(FAIL_STR) end
    end

    pn.UT_RAISES(func_that_throws, {66, 1, 2, 3}, FAIL_STR)
    pn.UT_RAISES(func_that_throws, {66, 1, 2, 3}, 'BOOM!')
    --function did raise expected error() but [.\test\test_pnut.lua:72: Fail => should be in report] does not contain [BOOM!].
    pn.UT_RAISES(func_that_throws, {6, 1, 2, 3}, 'BOOM!')
    --function did not raise expected error() with [BOOM!].

    -- Check summary. Cache values first.
    local num_suites_run = pn.num_suites_run
    local num_suites_failed = pn.num_suites_failed
    local num_cases_run = pn.num_cases_run
    local num_cases_failed = pn.num_cases_failed
    pn.UT_EQUAL(num_suites_run, 1)
    pn.UT_EQUAL(num_suites_failed, 1, "Info 6.")
    pn.UT_EQUAL(num_cases_run, 36)
    pn.UT_EQUAL(num_cases_failed, 17)

end

-----------------------------------------------------------------------------
-- Return the module.
return M
