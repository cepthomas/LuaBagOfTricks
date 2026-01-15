-- Unit tests for List.lua.

local sx = require("stringex")
local tx = require('tableex')
local List = require('List')


local M = {}

-- -----------------------------------------------------------------------------
-- function M.setup(pn)
-- end

-- -----------------------------------------------------------------------------
-- function M.teardown(pn)
-- end


---------------------------------------------------------------------------
function M.suite_success(pn)
    local res

    local list1 = List.new('pink bunny')
    list1:add_range({'fido', 'bonzo', 'moondoggie'})

    pn.UT_EQUAL(list1:count(), 3)
    local s = list1:dump()
    pn.UT_STR_EQUAL(s, 'fido,bonzo,moondoggie')
    pn.UT_STR_EQUAL(list1:name(), 'pink bunny')
    pn.UT_STR_EQUAL(list1:value_type(), 'string')
    pn.UT_STR_EQUAL(list1:class(), 'List')
    pn.UT_STR_EQUAL(tostring(list1), 'pink bunny(List)[string]')

    list1:add('end')
    pn.UT_EQUAL(list1:count(), 4)

    list1:insert(1, 'first')
    pn.UT_EQUAL(list1:count(), 5)
    list1:insert(4, 'middle')
    pn.UT_EQUAL(list1:count(), 6)
    --> { 'first', 'fido', 'bonzo', 'middle', 'moondoggie', 'end' }

    list1:add_range({ 'muffin', 'kitty', 'beetlejuice', 'tigger' })
    pn.UT_EQUAL(list1:count(), 10)
    --> { 'first', 'fido', 'bonzo', 'middle', 'moondoggie', 'end', 'muffin', 'kitty', 'beetlejuice', 'tigger' }

    pn.UT_EQUAL(list1:index_of('kitty'), 8)
    pn.UT_EQUAL(list1:index_of('nada'), nil)

    pn.UT_TRUE(list1:contains('moondoggie'))
    pn.UT_FALSE(list1:contains('hoody'))


    list1:sort(function(a, b) return a < b end)
    --> 'beetlejuice', 'bonzo', 'end', 'fido', 'first', 'kitty', 'middle', 'moondoggie', 'muffin', 'tigger'
    pn.UT_EQUAL(list1:count(), 10)
    pn.UT_STR_EQUAL(list1[5], 'first')

    list1:reverse()
    --> 'tigger', 'muffin', 'moondoggie', 'middle', 'kitty', 'first', 'fido', 'end', 'bonzo', 'beetlejuice',
    pn.UT_EQUAL(list1:count(), 10)
    pn.UT_STR_EQUAL(list1[5], 'kitty')

    res = list1:get_range() -- clone
    pn.UT_EQUAL(tx.table_count(res), 10)
    pn.UT_STR_EQUAL(res[2], 'muffin')

    res = list1:get_range(5) -- rh
    --> 'kitty', 'first', 'fido', 'end', 'bonzo', 'beetlejuice',
    pn.UT_EQUAL(tx.table_count(res), 6)
    pn.UT_STR_EQUAL(res[3], 'fido')

    res = list1:get_range(3, 6) -- subset
    --> 'moondoggie', 'middle', 'kitty', 'first', 'fido', 'end'
    pn.UT_EQUAL(tx.table_count(res), 6)
    pn.UT_STR_EQUAL(res[4], 'first')

    list1:remove_at(5)
    pn.UT_EQUAL(list1:count(), 9)

    list1:remove('middle')
    pn.UT_EQUAL(list1:count(), 8)

    list1:remove('fake')
    pn.UT_EQUAL(list1:count(), 8)

    list1:clear()
    pn.UT_EQUAL(list1:count(), 0)

    -- find
    local list2 = List.new('find')
    list2:add_range({ 'muffin', 'xxx', 'kitty', 'beetlejuice', 'tigger', 'xxx', 'fido', 'bonzo', 'moondoggie', 'xxx' })
    local ind = list2:find('zzz')
    pn.UT_NIL(ind)
    ind = list2:find('xxx')
    pn.UT_EQUAL(ind, 2)
    ind = list2:find('xxx', ind + 1)
    pn.UT_EQUAL(ind, 6)
    ind = list2:find('xxx', ind + 1)
    pn.UT_EQUAL(ind, 10)
    ind = list2:find('xxx', ind + 1)
    pn.UT_NIL(ind)
    res = list2:find_all(function(v) return sx.contains(v, 'zzzzzz') end)
    pn.UT_EQUAL(tx.table_count(res), 0)
    res = list2:find_all(function(v) return sx.contains(v, 't') end)
    pn.UT_EQUAL(tx.table_count(res), 3)

end

-----------------------------------------------------------------------------
function M.suite_fail(pn)

    local co = coroutine.create(function () end)

    local list3 = List.new()
    pn.UT_RAISES(list3.add_range, { self, { 'muffin', 'kitty', 9, 'beetlejuice', 'tigger' }}, 'Invalid value type: integer')

    list3 = List.new()
    list3:add_range({ 'muffin', 'kitty', 'beetlejuice', 'tigger' })
    pn.UT_RAISES(list3.add, { self, true }, 'Invalid value type: boolean')

    list3 = List.new()
    list3:add_range({ 'muffin', 'kitty', 'beetlejuice', 'tigger' })
    pn.UT_RAISES(list3.insert, { self, 3, co }, 'Invalid value type: thread')

end

-----------------------------------------------------------------------------
-- Return the module.
return M
