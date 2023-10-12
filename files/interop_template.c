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

ADD_INCLUDE


//---------------- Call lua functions from host - export_lua_funcs -------------//
RET_TYPE HOST_FUNC_NAME(ARG_TYPE_1 ARG_NAME_1, ARG_TYPE_2 ARG_NAME_2, ARG_TYPE_3 ARG_NAME_3, ...)
{
    RET_TYPE ret = NULL;

    // Get function.
    int ltype = lua_getglobal(l, LUA_FUNC_NAME);
    if (ltype != LUA_TFUNCTION) { ErrorHandler(l, LUA_ERRSYNTAX, "Bad lua function: %s", LUA_FUNC_NAME); }

    // Push arguments - loop.
    lua_push_ARG_TYPE_1(l, ARG_NAME_1);
    lua_push_ARG_TYPE_2(l, ARG_NAME_2);
    lua_push_ARG_TYPE_3(l, ARG_NAME_3);

    // Do the actual call.
    int lstat = luaL_docall(l, NUM_ARGS, NUM_RET);
    if (lstat >= LUA_ERRRUN) { ErrorHandler(l, lstat, "luaL_docall() failed"); }

    // Get the results from the stack.
    ret = $lua_to_RET_TYPE(l, -1);
    if (ret == NULL) { ErrorHandler(l, LUA_ERRSYNTAX, "Return value is not a RET_TYPE"); }
    lua_pop(l, num_ret);

    return ret;
}

//---------------- Call host functions from Lua - export_host_funcs -------------//
static int HOST_FUNC_NAME(lua_State* l)
{
    // Get arguments - loop.
    ARG_TYPE_1? ARG_NAME_1 = null;
    ARG_TYPE_2? ARG_NAME_2 = null;
    if (lua_is_ARG_TYPE_1(l, 1)) { arg1 = lua_to_ARG_TYPE_1(l, 1); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for %s", ARG_NAME_1); }
    if (lua_is_ARG_TYPE_2(l, 2)) { arg2 = lua_to_ARG_TYPE_2(l, 2); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for %s", ARG_NAME_2); }

    // Do the work.
    RET_TYPE ret = WORK_FUNC(ARG_NAME_1, ARG_NAME_2, ...);

    // Return result (one).
    lua_push_RET_TYPE(l, ret);
    return 1;
}

//------------------ Infrastructure ----------------------//
static const luaL_Reg function_map[] =
{
    { export_host_funcs.LUA_FUNC_NAME, export_host_funcs.HOST_FUNC_NAME },
    // etc.
    { NULL, NULL }
};

int interop_Open(lua_State* l)
{
    luaL_newlib(l, function_map);
    return 1;
}

void interop_Load(lua_State* l)
{
    luaL_requiref(l, LIB_NAME, interop_Open, true);
}
