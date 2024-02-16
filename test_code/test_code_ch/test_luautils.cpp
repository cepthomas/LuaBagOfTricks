#include <cstdio>
#include <cstring>

#include "pnut.h"

extern "C"
{
#include "luautils.h"
}


/////////////////////////////////////////////////////////////////////////////
UT_SUITE(LUAUTILS_MAIN, "Test luautils.") // TODO2 hook this in somewhere.
{
    double dval;
    int ival;
    bool ok;

    ok = luautils_ParseDouble("1859.371", &dval, 300.1, 1900.9);
    UT_TRUE(ok);
    UT_CLOSE(dval, 1859.371, 0.0001);

    ok = luautils_ParseDouble("-204.91", &dval, -300.1, 300.9);
    UT_TRUE(ok);
    UT_CLOSE(dval, -204.91, 0.001);

    ok = luautils_ParseDouble("555.55", &dval, 300.1, 500.9);
    UT_FALSE(ok);

    ok = luautils_ParseDouble("invalid", &dval, 300.1, 500.9);
    UT_FALSE(ok);

    ok = luautils_ParseInt("1859", &ival, 300, 1900);
    UT_TRUE(ok);
    UT_EQUAL(ival, 1859);

    ok = luautils_ParseInt("-204", &ival, -300, 300);
    UT_TRUE(ok);
    UT_EQUAL(ival, -204);

    ok = luautils_ParseInt("555", &ival, 300, 500);
    UT_FALSE(ok);

    ok = luautils_ParseInt("invalid", &ival, 300, 500);
    UT_FALSE(ok);

    return 0;
}    
