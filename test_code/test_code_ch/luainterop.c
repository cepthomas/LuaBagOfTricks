///// Warning - this file is created by gen_interop.lua, do not edit. /////

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <float.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "luainterop.h"
#include "luaex.h"

#include "another.h"

#if defined(_MSC_VER)
// Ignore some generated code warnings
#pragma warning( push )
#pragma warning( disable : 6001 4244 4703 )
#endif

//---------------- Call lua functions from host -------------//

//--------------------------------------------------------//
int luainterop_MyLuaFunc(lua_State* l, const char* arg_one, int arg_two, int arg_three, int* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "my_lua_func");
    if (ltype != LUA_TFUNCTION) { stat = INTEROP_BAD_FUNC_NAME; }

    if (stat == LUA_OK)
    {
        // Push arguments. No error checking required.
        lua_pushstring(l, arg_one);
        num_args++;
        lua_pushinteger(l, arg_two);
        num_args++;
        lua_pushinteger(l, arg_three);
        num_args++;

        // Do the actual call. If script fails, luaex_docall adds the script stack to the error object.
        stat = luaex_docall(l, num_args, num_ret);
    }

    if (stat == LUA_OK)
    {
        // Get the results from the stack.
        if (lua_tointeger(l, -1)) { *ret = lua_tointeger(l, -1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}

//--------------------------------------------------------//
int luainterop_MyLuaFunc2(lua_State* l, bool arg_one, double* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "my_lua_func2");
    if (ltype != LUA_TFUNCTION) { stat = INTEROP_BAD_FUNC_NAME; }

    if (stat == LUA_OK)
    {
        // Push arguments. No error checking required.
        lua_pushboolean(l, arg_one);
        num_args++;

        // Do the actual call. If script fails, luaex_docall adds the script stack to the error object.
        stat = luaex_docall(l, num_args, num_ret);
    }

    if (stat == LUA_OK)
    {
        // Get the results from the stack.
        if (lua_tonumber(l, -1)) { *ret = lua_tonumber(l, -1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}

//--------------------------------------------------------//
int luainterop_NoArgsFunc(lua_State* l, double* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "no_args_func");
    if (ltype != LUA_TFUNCTION) { stat = INTEROP_BAD_FUNC_NAME; }

    if (stat == LUA_OK)
    {
        // Push arguments. No error checking required.

        // Do the actual call. If script fails, luaex_docall adds the script stack to the error object.
        stat = luaex_docall(l, num_args, num_ret);
    }

    if (stat == LUA_OK)
    {
        // Get the results from the stack.
        if (lua_tonumber(l, -1)) { *ret = lua_tonumber(l, -1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}


//---------------- Call host functions from Lua -------------//

//--------------------------------------------------------//
// Host export function: fooga
// @param[in] l Internal lua state.
// @return Number of lua return values.
// Lua arg: arg_one kakakakaka
// Lua return: bool required return value
static int luainterop_MyLuaFunc3(lua_State* l)
{
    // Get arguments
    double arg_one;
    if (lua_isnumber(l, 1)) { arg_one = lua_tonumber(l, 1); }
    else { luaL_error(l, "Bad arg type for arg_one"); }

    // Do the work. One result.
    bool ret = luainteropwork_MyLuaFunc3(arg_one);
    lua_pushboolean(l, ret);
    return 1;
}

//--------------------------------------------------------//
// Host export function: Func with no args
// @param[in] l Internal lua state.
// @return Number of lua return values.
// Lua return: double a returned thing
static int luainterop_FuncWithNoArgs(lua_State* l)
{
    // Get arguments

    // Do the work. One result.
    double ret = luainteropwork_FuncWithNoArgs();
    lua_pushnumber(l, ret);
    return 1;
}


//---------------- Infrastructure -------------//

static const luaL_Reg function_map[] =
{
    { "my_lua_func3", luainterop_MyLuaFunc3 },
    { "func_with_no_args", luainterop_FuncWithNoArgs },
    { NULL, NULL }
};

static int luainterop_Open(lua_State* l)
{
    luaL_newlib(l, function_map);
    return 1;
}

void luainterop_Load(lua_State* l)
{
    luaL_requiref(l, "gen_lib", luainterop_Open, true);
}

#if defined(_MSC_VER)
#pragma warning( pop )
#endif
