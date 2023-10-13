// Warning - this is a generated file, do not edit.

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
// ALL functions - LOOP
RET_TYPE HOST_FUNC_NAME(ARG1_TYPE ARG1_NAME, ARG2_TYPE ARG2_NAME, ARG3_TYPE ARG3_NAME, ...)
{
    RET_TYPE ret = NULL;

    // Get function.
    int ltype = lua_getglobal(l, LUA_FUNC_NAME);
    if (ltype != LUA_TFUNCTION) { ErrorHandler(l, LUA_ERRSYNTAX, "Bad lua function: %s", LUA_FUNC_NAME); }

    // Push arguments - LOOP.
    lua_push_ARG1_TYPE(l, ARG1_NAME);
    lua_push_ARG2_TYPE(l, ARG2_NAME);
    lua_push_ARG3_TYPE(l, ARG3_NAME);
    //...

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
// ALL functions - LOOP
static int HOST_FUNC_NAME(lua_State* l)
{
    // Get arguments - LOOP.
    ARG1_TYPE? ARG1_NAME = null;
    if (lua_is_ARG1_TYPE(l, 1)) { arg1 = lua_to_ARG1_TYPE(l, 1); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for %s", ARG1_NAME); }
    ARG2_TYPE? ARG2_NAME = null;
    if (lua_is_ARG2_TYPE(l, 2)) { arg2 = lua_to_ARG2_TYPE(l, 2); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for %s", ARG2_NAME); }
    //...

    // Do the work.
    RET_TYPE ret = WORK_FUNC(ARG1_NAME, ARG2_NAME, ...);

    // Return result (one).
    lua_push_RET_TYPE(l, ret);
    return 1;
}

//------------------ Infrastructure ----------------------//

static const luaL_Reg function_map[] =
{
    // ALL collected
    { export_host_funcs.LUA_FUNC_NAME, export_host_funcs.HOST_FUNC_NAME },
    //...
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
