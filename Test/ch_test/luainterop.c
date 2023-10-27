///// Warning - this file is created by gen_interop.lua, do not edit. /////
//#include <stdlib.h>
//#include <stdio.h>
//#include <stdarg.h>
//#include <stdbool.h>
//#include <stdint.h>
//#include <string.h>
//#include <float.h>
//#include <math.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"
#include "luainterop.h"
#include <errno.h>
#include "other.h"

//---------------- Call lua functions from host -------------//

tableex* luainterop_MyLuaFunc(lua_State* l, char* arg_one, int arg_two, tableex* arg_three)
{
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "my_lua_func");
    if (ltype != LUA_TFUNCTION) { ErrorHandler(l, LUA_ERRSYNTAX, "Bad lua function: %s", my_lua_func); return NULL; };

    // Push arguments.
    lua_pushstring(l, arg_one);
    num_args++;
    lua_pushinteger(l, arg_two);
    num_args++;
    lua_pushtable(l, arg_three);
    num_args++;

    // Do the actual call.
    int lstat = luaL_docall(l, num_args, num_ret); // optionally throws
    if (lstat >= LUA_ERRRUN) { ErrorHandler(l, lstat, "luaL_docall() failed"); return NULL; }

    // Get the results from the stack.
    tableex* ret = lua_totable(l, -1);
    if (ret is NULL) { ErrorHandler(ErrorHandler(l, LUA_ERRSYNTAX, "Return is not a tableex*"); return NULL; }
    lua_pop(l, num_ret); // Clean up results.
    return ret;
}

double luainterop_MyLuaFunc2(lua_State* l, bool arg_one)
{
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "my_lua_func2");
    if (ltype != LUA_TFUNCTION) { ErrorHandler(l, LUA_ERRSYNTAX, "Bad lua function: %s", my_lua_func2); return NULL; };

    // Push arguments.
    lua_pushboolean(l, arg_one);
    num_args++;

    // Do the actual call.
    int lstat = luaL_docall(l, num_args, num_ret); // optionally throws
    if (lstat >= LUA_ERRRUN) { ErrorHandler(l, lstat, "luaL_docall() failed"); return NULL; }

    // Get the results from the stack.
    double ret = lua_tonumber(l, -1);
    if (ret is NULL) { ErrorHandler(ErrorHandler(l, LUA_ERRSYNTAX, "Return is not a double"); return NULL; }
    lua_pop(l, num_ret); // Clean up results.
    return ret;
}

double luainterop_NoArgsFunc(lua_State* l, )
{
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "no_args_func");
    if (ltype != LUA_TFUNCTION) { ErrorHandler(l, LUA_ERRSYNTAX, "Bad lua function: %s", no_args_func); return NULL; };

    // Push arguments.

    // Do the actual call.
    int lstat = luaL_docall(l, num_args, num_ret); // optionally throws
    if (lstat >= LUA_ERRRUN) { ErrorHandler(l, lstat, "luaL_docall() failed"); return NULL; }

    // Get the results from the stack.
    double ret = lua_tonumber(l, -1);
    if (ret is NULL) { ErrorHandler(ErrorHandler(l, LUA_ERRSYNTAX, "Return is not a double"); return NULL; }
    lua_pop(l, num_ret); // Clean up results.
    return ret;
}


//---------------- Call host functions from Lua -------------//

// Host export function: fooga
// Lua arg: "arg_one">kakakakaka
// Lua return: bool required return value
// @param[in] l Internal lua state.
// @return Number of lua return values.
static int luainterop_MyLuaFunc(lua_State* l)
{
    // Get arguments
    double arg_one;
    if (lua_isnumber(l, 1)) { arg_one = lua_tonumber(l, 1); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for arg_one"); return 0; }

    // Do the work. One result.
    bool ret = luainterop_MyLuaFuncWork(arg_one);
    lua_pushboolean(l, ret);
    return 1;
}

// Host export function: Func with no args
// Lua return: double a returned thing
// @param[in] l Internal lua state.
// @return Number of lua return values.
static int luainterop_FuncWithNoArgs(lua_State* l)
{
    // Get arguments

    // Do the work. One result.
    double ret = luainterop_FuncWithNoArgsWork();
    lua_pushnumber(l, ret);
    return 1;
}


//---------------- Infrastructure -------------//

static const luaL_Reg function_map[] =
{
    _MyLuaFunc = luainterop_MyLuaFunc;
    _FuncWithNoArgs = luainterop_FuncWithNoArgs;
    { NULL, NULL }
};

static int luainterop_Open(lua_State* l)
{
    luaL_newlib(l, function_map);
    return 1;
}

void luainterop_Load(lua_State* l)
{
    luaL_requiref(l, , luainterop_Open, true);
}
