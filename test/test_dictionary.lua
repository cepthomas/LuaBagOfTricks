-- Unit tests for Dictionary.lua.

local tx = require("tableex")
-- local ut = require("lbot_utils")
local Dictionary = require("Dictionary")

local M = {}


-- -----------------------------------------------------------------------------
-- function M.setup(pn)
-- end

-- -----------------------------------------------------------------------------
-- function M.teardown(pn)
-- end


---------------------------------------------------------------------------
function M.suite_success(pn)

    local d1 = Dictionary.new('green dragon')
    d1:add_range({ aa=100, bb=200, cc=300, dd=400, ee=500 })

    pn.UT_EQUAL(d1:count(), 5)
    pn.UT_EQUAL(d1['dd'], 400)
    pn.UT_EQUAL(d1.bb, 200)

    local s = d1:dump()
    pn.UT_STR_CONTAINS(s, 'bb[S]:200[N]')

    pn.UT_STR_EQUAL(d1:class(), 'Dictionary')
    pn.UT_STR_EQUAL(d1:name(), 'green dragon')
    pn.UT_STR_EQUAL(d1:key_type(), 'string')
    pn.UT_STR_EQUAL(d1:value_type(), 'integer')
    pn.UT_STR_EQUAL(tostring(d1), 'green dragon(Dictionary)[string:integer]')

    local l = d1:keys()
    pn.UT_EQUAL(tx.table_count(l), 5)

    l = d1:values()
    pn.UT_EQUAL(tx.table_count(l), 5)

    local t2 = { xx=808, yy=909 }

    d1:add_range(t2)
    pn.UT_EQUAL(d1:count(), 7)

    pn.UT_EQUAL(d1:contains_value(400), 'dd')
    pn.UT_EQUAL(d1:contains_value(808), 'xx')
    pn.UT_NIL(d1:contains_value('nada'))

    d1['ijk'] = 777
    pn.UT_EQUAL(d1:count(), 8)
    pn.UT_EQUAL(d1:contains_value(777), 'ijk')

    d1:clear()
    pn.UT_EQUAL(d1:count(), 0)

end

-----------------------------------------------------------------------------
function M.suite_fail(pn)

    local co = coroutine.create(function () end)

    local d1 = Dictionary.new()
    pn.UT_RAISES(d1.add_range, { self, { aa=100, bb=200, [true]=300, dd=400, ee=500 }}, 'Invalid key type: boolean')

    d1 = Dictionary.new()
    pn.UT_RAISES(d1.add_range, { self, { aa=100, bb=200, cc=300, dd=co, ee=500 }}, 'Invalid value type: thread')

    -- TODOL use UT_RAISES()
    d1 = Dictionary.new()
    d1:add_range({ aa=100, bb=200, cc=300, dd=400, ee=500 })
    -- d1[co] = 123 --> 'Invalid key type: thread'  

    d1 = Dictionary.new()
    d1:add_range({ aa=100, bb=200, cc=300, dd=400, ee=500 })
    -- d1.dd = nil --> 'Invalid value type: nil'

end

-----------------------------------------------------------------------------
-- Return the module.
return M
