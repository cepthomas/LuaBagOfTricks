-- Unit tests for stringex.lua.

local sx = require("stringex")

local M = {}

-- -----------------------------------------------------------------------------
-- function M.setup(pn)
--     -- pn.UT_INFO("setup()!!!")
-- end

-- -----------------------------------------------------------------------------
-- function M.teardown(pn)
--     -- pn.UT_INFO("teardown()!!!")
-- end

-----------------------------------------------------------------------------
function M.suite_stringex(pn)

    -- Test strtrim().
    local s = "  I have whitespace    "
    pn.UT_EQUAL(sx.strtrim(s), "I have whitespace")

    -- Test strjoin().
    local l = {123, "orange monkey", 765.12, "BlueBlueBlue", "ano", "ther", 222}
    pn.UT_EQUAL(sx.strjoin("XXX", l), "123XXXorange monkeyXXX765.12XXXBlueBlueBlueXXXanoXXXtherXXX222")

    -- Test strsplit().
    s = "Ut,,turpis,   adipiscing,luctus,,pharetra   ,condimentum, "
    -- Without trim.
    l = sx.strsplit(s, ",", false)
    pn.UT_EQUAL(#l, 9, "Number of list entries")
    pn.UT_STR_EQUAL(l[1], "Ut")
    pn.UT_STR_EQUAL(l[2], "")
    pn.UT_STR_EQUAL(l[3], "turpis")
    pn.UT_STR_EQUAL(l[4], "   adipiscing")
    pn.UT_STR_EQUAL(l[5], "luctus")
    pn.UT_STR_EQUAL(l[6], "")
    pn.UT_STR_EQUAL(l[7], "pharetra   ")
    pn.UT_STR_EQUAL(l[8], "condimentum")
    pn.UT_STR_EQUAL(l[9], " ")
    -- With trim.
    l = sx.strsplit(s, ",", true)
    pn.UT_EQUAL(#l, 6, "Number of list entries")
    pn.UT_STR_EQUAL(l[1], "Ut")
    pn.UT_STR_EQUAL(l[2], "turpis")
    pn.UT_STR_EQUAL(l[3], "adipiscing")
    pn.UT_STR_EQUAL(l[4], "luctus")
    pn.UT_STR_EQUAL(l[5], "pharetra")
    pn.UT_STR_EQUAL(l[6], "condimentum")

    s = "No delimiters in here"
    l = sx.strsplit(s, ".")
    pn.UT_EQUAL(#l, 1, "Number of list entries")
    pn.UT_STR_EQUAL(l[1], "No delimiters in here")
    pn.UT_NIL(l[2])

    -- Test interp().
    -- Simple interpolated string function. Stolen/modified from http://lua-users.org/wiki/StringInterpolation.
    -- @param str Source string.
    -- @param vars Replacement values dict.
    s = sx.interp( [[Hello {name}, welcome to {company}.]], { name = 'roberto', company = 'thieves inc' } )
    pn.UT_STR_EQUAL(s, "Hello roberto, welcome to thieves inc.")

    -- Test ...with().
    s = "luctus Ut adipiscing condimentum "
    pn.UT_TRUE(sx.startswith(s, "luctus "))
    pn.UT_FALSE(sx.startswith(s, " luc"))
    pn.UT_FALSE(sx.startswith(s, "xyz"))
    pn.UT_TRUE(sx.endswith(s, "ntum "))
    pn.UT_FALSE(sx.endswith(s, "ntum"))
    pn.UT_FALSE(sx.endswith(s, "xyz"))

end

-----------------------------------------------------------------------------
-- Return the module.
return M
