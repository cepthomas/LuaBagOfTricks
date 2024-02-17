#include <cstdio>
#include <cstring>

#include "pnut.h"

extern "C"
{
#include "luautils.h"
}


/////////////////////////////////////////////////////////////////////////////
UT_SUITE(LUAUTILS_MAIN, "Test luautils.") // TODO1 hook this in somewhere and add new ones.
{
    double dval;
    int ival;
    bool ok;


/*
/// Dump the lua stack contents.
/// @param L Lua state.
/// @param fout where to boss.
/// @param info Extra info.
int luautils_DumpStack(lua_State *L, FILE* fout, const char* info);

// /// Report a bad thing detected by this component.
// /// @param L Lua state.
// /// @param fout where to boss.
// /// @param err Specific Lua error.
// /// @param format Standard string stuff.
// void luautils_LuaError(lua_State* L, FILE* fout, int err, const char* format, ...);

/// Make a readable string.
/// @param status Specific Lua status.
/// @return the string.
const char* luautils_LuaStatusToString(int err);

/// Dump the table at the top.
/// @param L Lua state.
/// @param fout where to boss.
/// @param L name visual.
int luautils_DumpTable(lua_State* L, FILE* fout, const char* name);

/// Dump the lua globals.
/// @param L Lua state.
/// @param fout where to boss.
int luautils_DumpGlobals(lua_State* L, FILE* fout);

// /// Check stack.
// void luautils_EvalStack(lua_State* l, FILE* fout, int expected);

/// Safe convert a string to double with bounds checking.
/// @param[in] str to parse
/// @param[out] val answer
/// @param[in] min limit inclusive
/// @param[in] max limit inclusive
/// @return success
bool luautils_ParseDouble(const char* str, double* val, double min, double max);

/// Safe convert a string to int with bounds checking.
/// @param[in] str to parse
/// @param[out] val answer
/// @param[in] min limit inclusive
/// @param[in] max limit inclusive
/// @return success
bool luautils_ParseInt(const char* str, int* val, int min, int max);

*/




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
