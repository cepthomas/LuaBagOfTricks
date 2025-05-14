-- Unit tests for Tableex.lua.

local ut = require("lbot_utils")
local tx = require("tableex")
local sx = require("stringex")

local M = {}


-- -----------------------------------------------------------------------------
-- function M.setup(pn)
-- end

-- -----------------------------------------------------------------------------
-- function M.teardown(pn)
-- end

local tt =
{
    aa="pt1",
    bb=90901,
    alist=
    {
        "qwerty",
        777,
        temb1=
        {
            jj="pt8",
            b=true,
            temb2=
            {
                num=1.517,
                dd="strdd"
            }
        },
        intx=5432
    },
    cc=function() end,
    [101]='booga'
}


-----------------------------------------------------------------------------
function M.suite_success(pn)

    -- basic functions
    pn.UT_EQUAL(tx.table_count(tt), 5)
    pn.UT_EQUAL(tx.table_count(tt.alist), 4)

    -- dump_table()
    local s = tx.dump_table(tt)
    pn.UT_EQUAL(#s, 148)

    local s = tx.dump_table(tt, 'depth0', 0)
    pn.UT_EQUAL(#s, 145)

    s = tx.dump_table(tt, 'depth1', 1)
    pn.UT_EQUAL(#s, 229)

    s = tx.dump_table(tt, 'depth2', 2)
    pn.UT_EQUAL(#s, 300)

    s = tx.dump_table(tt, 'depth3', 3)
    pn.UT_EQUAL(#s, 336)

    s = tx.dump_table(tt, 'depth4', 4)
    pn.UT_EQUAL(#s, 336)

    -- misc functions
    pn.UT_TRUE(tx.contains_value(tt, 'booga'))
    pn.UT_FALSE(tx.contains_value(tt, 'ack'))

    local tc = tx.copy(tt) -- shallow
    pn.UT_EQUAL(tx.table_count(tc), 5)
    s = tx.dump_table(tc)
    pn.UT_EQUAL(#s, 148)

    tc = tx.deep_copy(tt)
    s = tx.dump_table(tc, 'depthc', 4)
    pn.UT_EQUAL(#s, 336) -- same as 'depth4'

    -- sequence-like tables
    local tl = {'aaa', 'bbb', 'ccc', 'ddd', 'eee'}
    s = tx.dump_list(tl)
    pn.UT_EQUAL(s, 'aaa,bbb,ccc,ddd,eee')

end


-----------------------------------------------------------------------------
-- Return the module.
return M
