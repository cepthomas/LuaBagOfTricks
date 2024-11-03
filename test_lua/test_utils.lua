-- TODOT Unit tests for the utils.

local sx = require("stringex")
local ut = require("lbot_utils")

-- print('!!!', package.path)

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
function M.suite_dump_table(pn)

    -- Test dump_table().
    local tt = { aa="pt1", bb=90901, alist={ "qwerty", 777, temb1={ jj="pt8", b=true, temb2={ num=1.517, dd="strdd" } }, intx=5432}}

    local d = ut.dump_table(tt, 0)
    pn.UT_EQUAL(#d, 4)

    d = ut.dump_table(tt, 1)
    pn.UT_EQUAL(#d, 8)

    d = ut.dump_table(tt, 2)
    pn.UT_EQUAL(#d, 11)

    d = ut.dump_table(tt, 3)
    pn.UT_EQUAL(#d, 13)

    d = ut.dump_table(tt, 4)
    pn.UT_EQUAL(#d, 13)

    local s = ut.dump_table_string(tt, 0, 'howdy')
    pn.UT_EQUAL(#s, 94)

    s = ut.dump_table_string(tt, 1)
    pn.UT_EQUAL(#s, 191)

    s = ut.dump_table_string(tt, 2)
    pn.UT_EQUAL(#s, 272)

    s = ut.dump_table_string(tt, 3)
    pn.UT_EQUAL(#s, 316)

    s = ut.dump_table_string(tt, 4)
    pn.UT_EQUAL(#s, 316)

end

-----------------------------------------------------------------------------
function M.suite_validation(pn)

    local tt = { aa="pt1", bb=90901, alist={ "qwerty", 777, temb1={ jj="pt8", b=true, temb2={ num=1.517, dd="strdd" } }, intx=5432}}

    -- -- @return integer or nil if not convertible
    -- function M.to_integer(v)


    -- -- @return return ok or nil,errmsg if not.
    -- function M.val_number(v, min, max, name)
    -- function M.val_integer(v, min, max, name)
    -- function M.val_string(v, name)
    -- function M.val_boolean(v, name)
    -- function M.val_table(v, name)
    -- function M.val_function(v, name)


    local res, err

    res, err = ut.val_number(13.4, 13.3, 13.5, 'v1')
    pn.UT_NOT_NIL(res)
    res, err = ut.val_number(13.4, 13.3, 13.5, 'v1')
    pn.UT_NOT_NIL(res)
    res, err = ut.val_number(13.4, 13.9, 13.5, 'v1')
    pn.UT_NIL(res)

    res, err = ut.val_integer(13.4, 13.3, 13.5, 'v1')
    pn.UT_NOT_NIL(res)

    res, err = ut.val_string(13.4, 13.3)
    pn.UT_NOT_NIL(res)

    res, err = ut.val_boolean(13.4, 13.3)
    pn.UT_NOT_NIL(res)

    res, err = ut.val_table(13.4, 13.3)
    pn.UT_NOT_NIL(res)

    res, err = ut.val_function(13.4, 13.3)
    pn.UT_NOT_NIL(res)




-- function M.UT_CLOSE(val1, val2, tol, info)
-- function M.UT_EQUAL(val1, val2, info)
-- function M.UT_ERROR(info)
-- function M.UT_FALSE(expr, info)
-- function M.UT_GREATER(val1, val2, info)
-- function M.UT_GREATER_OR_EQUAL(val1, val2, info)
-- function M.UT_INFO(info)
-- function M.UT_LESS(val1, val2, info)
-- function M.UT_LESS_OR_EQUAL(val1, val2, info)
-- function M.UT_NIL(expr, info)
-- function M.UT_NOT_EQUAL(val1, val2, info)
-- function M.UT_NOT_NIL(expr, info)
-- function M.UT_STR_CONTAINS(val, phrase, info)
-- function M.UT_STR_EQUAL(val1, val2, info)
-- function M.UT_STR_NOT_EQUAL(val1, val2, info)
-- function M.UT_TRUE(expr, info)


end

-----------------------------------------------------------------------------
-- Return the module.
return M
