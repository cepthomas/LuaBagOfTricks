-- Unit tests for lbot_types.lua.

local lt = require("lbot_types")
local tx = require("tableex")


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
function M.suite_basic_types(pn)

    pn.UT_TRUE(lt.is_integer(101))
    pn.UT_FALSE(lt.is_integer(101.0001))

    local function hoohaa() end
    pn.UT_TRUE(lt.is_callable(hoohaa))
    pn.UT_FALSE(lt.is_callable('abcdef'))

    local tbl1 = { 'aaa', 'bbb', 333 }
    local tbl2 = { ['aaa']=777; ['bbb']='uuu'; [333]=122.2 }
    pn.UT_TRUE(lt.is_indexable(tbl1))
    pn.UT_TRUE(lt.is_indexable(tbl2))

    pn.UT_TRUE(lt.is_iterable(tbl1))
    pn.UT_TRUE(lt.is_iterable(tbl2))

    pn.UT_FALSE(lt.is_iterable('rrr'))
    pn.UT_FALSE(lt.is_iterable(123))

    pn.UT_TRUE(lt.is_writeable(tbl1))
    pn.UT_FALSE(lt.is_writeable(2.2))

    local res = lt.tointeger(123)
    pn.UT_EQUAL(res, 123)
    res = lt.tointeger(123.1)
    pn.UT_EQUAL(res, nil)
    res = lt.tointeger('123')
    pn.UT_EQUAL(res, 123)

end

-----------------------------------------------------------------------------
function M.suite_validators(pn)

    local res

    ----- number
    lt.val_number(13.4, 13.3, 13.5)
    lt.val_number(13.4)
    -- Wrong type
    pn.UT_RAISES(lt.val_number, {'13.4', 13.3, 13.5}, 'Invalid number:13.4')
    -- Below
    pn.UT_RAISES(lt.val_number, {13.2, 13.3, 13.5}, 'Invalid number:13.2')
    -- Above
    pn.UT_RAISES(lt.val_number, {13.6, 13.9, 13.5}, 'Invalid number:13.6')

    ----- integer
    lt.val_integer(271, 270, 272)
    lt.val_integer(271)
    -- Wrong type
    pn.UT_RAISES(lt.val_integer, {13.4, 13.3, 13.5}, 'Invalid integer:13.4')
    -- Below
    pn.UT_RAISES(lt.val_integer, {269, 270, 272}, 'Invalid integer:269')
    -- Above
    pn.UT_RAISES(lt.val_integer, {273, 270, 272}, 'Invalid integer:273')

    ----- table
    local tbl = {}
    lt.val_table(tbl)
    tbl = { 'aaa', 'bbb', 333 }
    lt.val_table(tbl, 3)
    -- pn.UT_RAISES(lt.val_table, {tbl, 4}, 'Sparse table: 4')
    pn.UT_RAISES(lt.val_table, {'tbl', 4}, 'Not a valid table')

    tbl = { 'aaa', bad='bbb', 333 }
    pn.UT_RAISES(lt.val_sequence, {tbl}, 'Not sequence type')
    tbl = {'one', 'two', 'three', 'four'}
    lt.val_sequence(tbl)
    tbl = {[2]='one', [9]='two', [5]='three', [1]='four'}
    pn.UT_RAISES(lt.val_sequence, {tbl}, 'Not sequence type')

    ----- misc
    lt.val_type(tbl, 'table')
    lt.val_type(123, 'integer')
    lt.val_type(123.1, 'number')
    lt.val_type(false, 'boolean')
    pn.UT_RAISES(lt.val_type, {'123', 'table'}, 'Invalid type:string')

    lt.val_not_nil(tbl)
    local vnil = nil
    pn.UT_RAISES(lt.val_not_nil, {vnil}, 'Value is nil')

    local function hoohaa() end
    lt.val_func(hoohaa)
    pn.UT_RAISES(lt.val_func, {123}, 'Invalid function')

end

-----------------------------------------------------------------------------
-- Return the module.
return M
