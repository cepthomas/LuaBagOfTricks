--[[
Unit tests for the utils.
Run like: lua pnut_runner.lua test_utils
--]]


ut = require("utils")

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
    pn.UT_INFO("Test all functions in utils.lua")

    -- Test strtrim().
    s = "  I have whitespace    "
    pn.UT_EQUAL(ut.strtrim(s), "I have whitespace")

    -- Test strjoin().
    l = {123, "orange monkey", 765.12, "BlueBlueBlue", "ano", "ther", 222}
    pn.UT_EQUAL(ut.strjoin("XXX", l), "123XXXorange monkeyXXX765.12XXXBlueBlueBlueXXXanoXXXtherXXX222")

    -- Test strsplit().
    l = ut.strsplit(",", "Ut,turpis,adipiscing,luctus,,pharetra,condimentum, ")
    pn.UT_EQUAL(#l, 8, "Number of list entries")
    pn.UT_EQUAL(l[1], "Ut")
    pn.UT_EQUAL(l[2], "turpis")
    pn.UT_EQUAL(l[3], "adipiscing")
    pn.UT_EQUAL(l[4], "luctus")
    pn.UT_EQUAL(l[5], "")
    pn.UT_EQUAL(l[6], "pharetra")
    pn.UT_EQUAL(l[7], "condimentum")

    -- Test array_from_file() for text data.
    ta = ut.array_from_file("files\\mixed_data.txt")
    pn.UT_EQUAL(#ta, 276, "Number of text fields")
    pn.UT_EQUAL(ta[1], "TS")
    pn.UT_EQUAL(ta[30], "71")
    pn.UT_EQUAL(ta[193], "CH3")
    pn.UT_EQUAL(ta[239], "4016")

    -- Test array_from_file() for numerical data.
    na = ut.array_from_file("files\\numerical_data.txt", true) -- remove blank fields
    pn.UT_EQUAL(#na, 89)
    pn.UT_EQUAL(tonumber(na[17]), 506)
    pn.UT_EQUAL(tonumber(na[45]), 12.93)
    pn.UT_EQUAL(tonumber(na[69]), 264302719)
    pn.UT_EQUAL(tonumber(na[89]), 1.11)
end

-----------------------------------------------------------------------------
-- Return the module.
return M
