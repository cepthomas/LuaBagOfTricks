-- Unit tests for lbot_utils.lua.

local ut = require("lbot_utils")
local tx = require("tableex")


local M = {}

Appglob1 = 888
Appglob3 = 333


-- -----------------------------------------------------------------------------
-- function M.setup(pn)
-- function M.teardown(pn)


-----------------------------------------------------------------------------
function M.suite_system(pn)

    accidental_global = 0

    local extraneous, unused = ut.check_globals({ 'Appglob1', 'Appglob2', 'Appglob3'})
    -- print(tx.dump_table(_G, '_G'))
    -- print(tx.dump_table(extraneous, 'extraneous', 1))
    -- print(tx.dump_table(unused, 'unused', 1))
    pn.UT_NOT_NIL(extraneous['accidental_global'])
    pn.UT_NIL(extraneous['_VERSION'])
    pn.UT_NOT_NIL(unused['Appglob2'])
    pn.UT_NIL(unused['Appglob1'])

    ut.fix_lua_path('/mypath')
    -- print(package.path)
    pn.UT_STR_CONTAINS(package.path, 'mypath')

    local res = ut.execute_and_capture('dir')
    pn.UT_STR_CONTAINS(res, 'lbot_utils.lua')
    pn.UT_STR_CONTAINS(res, '<DIR>          ..')

    local fpath, line, dir = ut.get_caller_info(2)
    pn.UT_EQUAL(line, 40) -- line of call above
    pn.UT_STR_CONTAINS(fpath, '\\test\\test_utils.lua')
    pn.UT_STR_CONTAINS(dir, '\\test')

    -- for i = 0, 6 do
    --     local fpath, line, dir = ut.get_caller_info(i)
    --     print(i..' '..fpath..'('..line..') dir['..dir..']')
    -- end

end

-----------------------------------------------------------------------------
function M.suite_math(pn)

    local res = ut.constrain(55, 107.6, 553)
    pn.UT_EQUAL(res, 107.6)

    res = ut.constrain(118.9, 107.6, 553)
    pn.UT_EQUAL(res, 118.9)

    res = ut.constrain(692, 107.6, 553)
    pn.UT_EQUAL(res, 553)

    res = ut.map(19.1, -100, 100, 30, 300)
    pn.UT_EQUAL(res, 190.785)

    res = ut.clamp(-22.84, 0.1, true)
    pn.UT_EQUAL(res, -22.8)

    res = ut.clamp(411, 5, false)
    pn.UT_EQUAL(res, 410)

end

-----------------------------------------------------------------------------
function M.suite_files(pn)

    local temp_fn = '_test_file.txt'
    ut.file_write_all(temp_fn, 'a new string')
    ut.file_append_all(temp_fn, 'a second string')
    local res = ut.file_read_all(temp_fn)
    pn.UT_STR_EQUAL(res, 'a new stringa second string')
    os.remove(temp_fn)

end

-----------------------------------------------------------------------------
function M.suite_misc(pn)

    local res = ut.ternary(5 > 4, 100, 200)
    pn.UT_EQUAL(res, 100)

    ut.set_colorize( { ['red']=91, ['green']=92, ['blue']=94, ['yellow']=33, ['gray']=95, ['bred']=41 } )

    -- res = ut.colorize_text('blabla')
    -- pn.UT_STR_EQUAL(res, 'blabla')

end

-----------------------------------------------------------------------------
-- Return the module.
return M
