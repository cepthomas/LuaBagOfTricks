-- 
Unit tests for the utils.

ut = require("utils")

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
    pn.UT_INFO("Test all functions in utils.lua")

    -- Test strtrim().
    local s = "  I have whitespace    "
    pn.UT_EQUAL(ut.strtrim(s), "I have whitespace")

    -- Test strjoin().
    local l = {123, "orange monkey", 765.12, "BlueBlueBlue", "ano", "ther", 222}
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

    -- Test dump_table().
    tt = { aa="pt1", bb=90901, arr={"qwerty", 777, temb1={ jj="pt8", b=true, temb2={ num=1.517, dd="strdd" } }, intx=5432}}
    local sts = ut.dump_table(tt, 0, true)
    s = ut.strjoin('\n', sts)
    pn.UT_EQUAL(#s, 250)

end

-----------------------------------------------------------------------------
-- Return the module.
return M
