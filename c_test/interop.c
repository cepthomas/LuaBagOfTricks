
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <float.h>
#include <errno.h>
#include <math.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"
#include "interop.h"

// lua_Integer lua_tointegerx (lua_State *L, int index, int *isnum);
// lua_Number lua_tonumberx (lua_State *L, int index, int *isnum);


// TODOGEN generator fills these in place:
#define my_lua_func_name_2 "call_my_host_func"
#define my_lua_func_name_1 "call_my_lua_func"
#define lib_name "neb_api"
int num_args;
int num_ret;


//---------------- Call lua functions from host -------------//

lua_tableex* interop_HostCallLua(lua_State* l, char* arg1, int arg2, lua_tableex* arg3)
{
    lua_tableex* ret = NULL;
    bool ok = true;
    // int lstat = LUA_OK;

    // Get the function to be called. Check return.
    int ltype = lua_getglobal(l, my_lua_func_name_1);

    if (ltype != LUA_TFUNCTION)
    {
        ok = false;
        ErrorHandler(l, LUA_ERRSYNTAX, "Bad lua function: %s", my_lua_func_name_1);
    }

    if (ok)
    {
        // Push the arguments to the call.
        lua_pushstring(l, arg1);
        lua_pushinteger(l, arg2);
        lua_pushtableex(l, arg3);

        // Do the actual call.
        int lstat = luaL_docall(l, num_args, num_ret); // optionally throws
        if (lstat >= LUA_ERRRUN)
        {
            ok = false;
            ErrorHandler(l, lstat, "luaL_docall() failed");
        }

        // Get any results from the stack.
        ret = lua_totableex(l, -1); // or ToInteger() etc
        if (ret == NULL)
        {
            ok = false;
            ErrorHandler(l, LUA_ERRSYNTAX, "Return is not a $table$");
        }

        lua_pop(l, num_ret); // Clean up results.
    }

    return ret;
}


//---------------- Call host functions from Lua -------------//

static int interop_LuaCallHost(lua_State* l)
{
    bool ok = true;
    int numres = 0;

    int arg1;
    const char* arg2;

    // Get args.
    if (ok)
    {
        if (lua_isinteger(l, 1))
        {
            arg1 = lua_tointeger(l, 1);
        }
        else
        {
            ok = false;
            ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for $arg1$");
        }
    }

    if (ok)
    {
        if (lua_isstring(l, 2))
        {
            arg2 = lua_tostring(l, 2);
        }
        else
        {
            ok = false;
            ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for $arg2$");
        }
    }

    if (ok)
    {
        // Do the work.
        double ret = interop_LuaCallHost_DoWork(arg1, arg2);

        // Return results.
        lua_pushnumber(l, ret);
        numres = 1;
    }

    return numres;
}


//------------------ Infrastructure ----------------------//

// Map lua functions to C functions.
static const luaL_Reg function_map[] =
{
    //lua func, C func
    { my_lua_func_name_2, interop_LuaCallHost },
    // etc.
    { NULL,     NULL }
};

// Callback from system to actually load the lib.
int interop_Open(lua_State* l)
{
    // Register our C <-> Lua functions.
    luaL_newlib(l, function_map);

    return 1;
}

//
void interop_Load(lua_State* l)
{
    // Load app stuff. This table gets pushed on the stack and into globals.
    luaL_requiref(l, lib_name, interop_Open, 1);
}
