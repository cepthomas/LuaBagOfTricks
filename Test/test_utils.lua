--[[

TODO1 fix like test_pnut
--]]

local ut = require("utils")
local tr = require("test_runner")

function do_tests()
    tr.test_set("test_lua_libs-1", "Unit testing of generators.lua, utils.lua.", ut.clean_svn("$URL: http://ocdusrow3rndd3:8686/NEPTUNE_SANDBOX/trunk/Build/Tools/scripts/test/test_utils.lua $"))

    ----------------------------- case 1 ------------------------------------------------
    tr.test_case("test_lua_libs-1-1", "Test all functions in utils.lua.")

    tr.test_step(2, "Test strtrim().")
    s = "  I have whitespace    "
    tr.test_check_e(ut.strtrim(s), "I have whitespace")

    tr.test_step(4, "Test strjoin().")
    l = {123, "orange monkey", 765.12, "BlueBlueBlue", "ano", "ther", 222}
    tr.test_check_e(ut.strjoin("XXX", l), "123XXXorange monkeyXXX765.12XXXBlueBlueBlueXXXanoXXXtherXXX222")

    tr.test_step(5, "Test strsplit().")
    l = ut.strsplit(",", "Ut,turpis,adipiscing,luctus,,pharetra,condimentum, ")
    tr.test_check_e(#l, 8, "Number of list entries")
    tr.test_check_e(l[1], "Ut")
    tr.test_check_e(l[2], "turpis")
    tr.test_check_e(l[3], "adipiscing")
    tr.test_check_e(l[4], "luctus")
    tr.test_check_e(l[5], "")
    tr.test_check_e(l[6], "pharetra")
    tr.test_check_e(l[7], "condimentum")

    tr.test_step(7, "Test array_from_file() for text data.")
    ta = ut.array_from_file("mixed_data.txt")
    tr.test_check_e(#ta, 276, "Number of text fields")
    tr.test_check_e(ta[1], "TS")
    tr.test_check_e(ta[30], "71")
    tr.test_check_e(ta[193], "CH3")
    tr.test_check_e(ta[239], "4016")

    tr.test_step(8, "Test array_from_file() for numerical data.")
    na = ut.array_from_file("numerical_data.txt", true) -- remove blank fields
    tr.test_check_e(#na, 89, "Number of numerical fields")
    tr.test_check_e(tonumber(na[17]), 506)
    tr.test_check_e(tonumber(na[45]), 12.93)
    tr.test_check_e(tonumber(na[69]), 264302719)
    tr.test_check_e(tonumber(na[89]), 1.11)

    ------------------ test complete -----------------------
    -- Don't forget to finish up the test. If cases or steps are added, this inspection needs to change also.
    tr.test_inspect("Test complete. Verify the report heading indicates correct Test Set, Test Script, and Run Start values.")
    s = "Verify the report summary indicates correct Test Run Finish time and " ..
    "Cases Run = 3, Cases Failed = 1, Steps Run = 17, Steps Failed = 1, Run Result = Fail."
    tr.test_inspect(s)
    tr.test_end()
end

-----------------------------------------------------------------------------
-- Module initialization.

do_tests()
