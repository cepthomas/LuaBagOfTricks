#include <cstdio>
#include <cstring>
#include <cstdio>
#include <cstring>
#include <fstream>

#include "pnut.h"

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luautils.h"
#include "logger.h"
}


// The main Lua thread.
static lua_State* _l;


/////////////////////////////////////////////////////////////////////////////
UT_SUITE(UTILS_MAIN, "Test luautils.") // TODO2 flesh out.
{
    //double dval;
    //int ival;
    //bool ok;
    //int stat = LUA_OK;
    //FILE* fout = stdout;

    /// Dump the lua stack contents.
    /// @param L Lua state.
    /// @param fout where to boss.
    /// @param info Extra info.
    //stat = luautils_DumpStack(_l, fout, "const char* info");


    /// Make a readable string.
    /// @param status Specific Lua status.
    /// @return the string.
    //const char* s = luautils_LuaStatusToString(LUA_OK);

    /// Dump the table at the top.
    /// @param L Lua state.
    /// @param fout where to boss.
    /// @param L name visual.
    //stat =  luautils_DumpTable(_l, fout, "const char* name");

    /// Dump the lua globals.
    /// @param L Lua state.
    /// @param fout where to boss.
    //stat =  luautils_DumpGlobals(_l, fout);

    /// Check stack.
    //luautils_EvalStack(_l, fout, 3);

    /// Safe convert a string to double with bounds checking.
    /// @param[in] str to parse
    /// @param[out] val answer
    /// @param[in] min limit inclusive
    /// @param[in] max limit inclusive
    /// @return success
    //ok = luautils_ParseDouble("const char* str", &dval, 1.0, 5.0);

    /// Safe convert a string to int with bounds checking.
    /// @param[in] str to parse
    /// @param[out] val answer
    /// @param[in] min limit inclusive
    /// @param[in] max limit inclusive
    /// @return success
    //ok = luautils_ParseInt("const char* str", &ival, 2, 6);

    return 0;
}    
