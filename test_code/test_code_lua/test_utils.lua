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
    s = ut.dump_table_string(tt, 0, true)
    pn.UT_EQUAL(#s, 310)

end

-----------------------------------------------------------------------------
-- Return the module.
return M
