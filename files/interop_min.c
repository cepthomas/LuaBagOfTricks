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

//------------------ generator creates these from spec --------------------//
// generator fills these in place:
// #define my_lua_func_name_2 "call_my_host_func"
// #define my_lua_func_name_1 "call_my_lua_func"
// #define lib_name "neb_api"
// int num_args;
// int num_ret;

//---------------- Call lua functions from host -------------//
lua_tableex* interop_HostCallLua(lua_State* l, char* arg1, int arg2, lua_tableex* arg3) // all these
{
    $lua_tableex*$ ret = NULL;
    // function
    int ltype = lua_getglobal(l, $my_lua_func_name_1$);
    if (ltype != LUA_TFUNCTION) { ErrorHandler(l, LUA_ERRSYNTAX, $"Bad lua function: {my_lua_func_name_1}"); }
    // args
    lua_pushstring(l, $arg1$);
    lua_pushinteger(l, $arg2$);
    lua_pushtableex(l, $arg3$);
    // do work and return
    int lstat = luaL_docall(l, num_args, num_ret);
    if (lstat >= LUA_ERRRUN) { ErrorHandler(l, lstat, "luaL_docall() failed"); }
    ret = $lua_totableex$(l, -1);
    if (ret == NULL) { ErrorHandler(l, LUA_ERRSYNTAX, "Return value is not a $table$"); }
    lua_pop(l, num_ret);
    return ret;
}

//---------------- Call host functions from Lua -------------//
static int interop_LuaCallHost(lua_State* l)
{
    int arg1;
    const char* arg2;
    // args
    if (lua_isinteger(l, 1)) { arg1 = lua_tointeger(l, 1); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for $arg1$"); }
    if (lua_isstring(l, 2)) { arg2 = lua_tostring(l, 2); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for $arg2$"); }
    // do work and return
    double ret = interop_LuaCallHost_DoWork(arg1, arg2);
    lua_pushnumber(l, ret);
    return $1;
}

//------------------ Infrastructure ----------------------//
static const luaL_Reg function_map[] =
{
    { my_lua_func_name_2, interop_LuaCallHost },
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
    luaL_requiref(l, lib_name, interop_Open, true);
}
