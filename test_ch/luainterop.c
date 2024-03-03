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


#if defined(_MSC_VER)
// Ignore some generated code warnings
#pragma warning( push )
#pragma warning( disable : 6001 4244 4703 4090 )
#endif

//---------------- Call lua functions from host -------------//

//--------------------------------------------------------//
int luainterop_Calculator(lua_State* l, double op_one, char* oper, double op_two, double* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "calculator");
    if (ltype != LUA_TFUNCTION) { stat = INTEROP_BAD_FUNC_NAME; }

    if (stat == LUA_OK)
    {
        // Push arguments. No error checking required.
        lua_pushnumber(l, op_one);
        num_args++;
        lua_pushstring(l, oper);
        num_args++;
        lua_pushnumber(l, op_two);
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
int luainterop_DayOfWeek(lua_State* l, char* day, int* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "day_of_week");
    if (ltype != LUA_TFUNCTION) { stat = INTEROP_BAD_FUNC_NAME; }

    if (stat == LUA_OK)
    {
        // Push arguments. No error checking required.
        lua_pushstring(l, day);
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
int luainterop_FirstDay(lua_State* l, char** ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "first_day");
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
        if (lua_tostring(l, -1)) { strncpy(*ret, lua_tostring(l, -1), MAX_STRING - 1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}

//--------------------------------------------------------//
int luainterop_InvalidFunc(lua_State* l, bool* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "invalid_func");
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
        if (lua_toboolean(l, -1)) { *ret = lua_toboolean(l, -1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}

//--------------------------------------------------------//
int luainterop_InvalidArgType(lua_State* l, char* arg1, bool* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "invalid_arg_type");
    if (ltype != LUA_TFUNCTION) { stat = INTEROP_BAD_FUNC_NAME; }

    if (stat == LUA_OK)
    {
        // Push arguments. No error checking required.
        lua_pushstring(l, arg1);
        num_args++;

        // Do the actual call. If script fails, luaex_docall adds the script stack to the error object.
        stat = luaex_docall(l, num_args, num_ret);
    }

    if (stat == LUA_OK)
    {
        // Get the results from the stack.
        if (lua_toboolean(l, -1)) { *ret = lua_toboolean(l, -1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}

//--------------------------------------------------------//
int luainterop_InvalidRetType(lua_State* l, int* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "invalid_ret_type");
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
        if (lua_tointeger(l, -1)) { *ret = lua_tointeger(l, -1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}

//--------------------------------------------------------//
int luainterop_ErrorFunc(lua_State* l, int flavor, bool* ret)
{
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "error_func");
    if (ltype != LUA_TFUNCTION) { stat = INTEROP_BAD_FUNC_NAME; }

    if (stat == LUA_OK)
    {
        // Push arguments. No error checking required.
        lua_pushinteger(l, flavor);
        num_args++;

        // Do the actual call. If script fails, luaex_docall adds the script stack to the error object.
        stat = luaex_docall(l, num_args, num_ret);
    }

    if (stat == LUA_OK)
    {
        // Get the results from the stack.
        if (lua_toboolean(l, -1)) { *ret = lua_toboolean(l, -1); }
        else { stat = INTEROP_BAD_RET_TYPE; }
        lua_pop(l, num_ret); // Clean up results.
    }

    return stat;
}


//---------------- Call host functions from Lua -------------//

//--------------------------------------------------------//
// Host export function: Record something for me.
// @param[in] l Internal lua state.
// @return Number of lua return values.
// Lua arg: level Log level.
// Lua arg: msg What to log.
// Lua return: bool Required dummy return value.
static int luainterop_Log(lua_State* l)
{
    // Get arguments
    int level;
    if (lua_isinteger(l, 1)) { level = lua_tointeger(l, 1); }
    else { luaL_error(l, "Bad arg type for level"); }
    char* msg;
    if (lua_isstring(l, 2)) { msg = lua_tostring(l, 2); }
    else { luaL_error(l, "Bad arg type for msg"); }

    // Do the work. One result.
    bool ret = luainteropwork_Log(level, msg);
    lua_pushboolean(l, ret);
    return 1;
}

//--------------------------------------------------------//
// Host export function: How hot are you?
// @param[in] l Internal lua state.
// @return Number of lua return values.
// Lua arg: temp Temperature.
// Lua return: char* String environment.
static int luainterop_GetEnvironment(lua_State* l)
{
    // Get arguments
    double temp;
    if (lua_isnumber(l, 1)) { temp = lua_tonumber(l, 1); }
    else { luaL_error(l, "Bad arg type for temp"); }

    // Do the work. One result.
    char* ret = luainteropwork_GetEnvironment(temp);
    lua_pushstring(l, ret);
    return 1;
}

//--------------------------------------------------------//
// Host export function: Milliseconds.
// @param[in] l Internal lua state.
// @return Number of lua return values.
// Lua return: int The time.
static int luainterop_GetTimestamp(lua_State* l)
{
    // Get arguments

    // Do the work. One result.
    int ret = luainteropwork_GetTimestamp();
    lua_pushinteger(l, ret);
    return 1;
}

//--------------------------------------------------------//
// Host export function: Raise an error from lua code.
// @param[in] l Internal lua state.
// @return Number of lua return values.
// Lua return: bool Required dummy return value.
static int luainterop_ForceError(lua_State* l)
{
    // Get arguments

    // Do the work. One result.
    bool ret = luainteropwork_ForceError();
    lua_pushboolean(l, ret);
    return 1;
}


//---------------- Infrastructure -------------//

static const luaL_Reg function_map[] =
{
    { "log", luainterop_Log },
    { "get_environment", luainterop_GetEnvironment },
    { "get_timestamp", luainterop_GetTimestamp },
    { "force_error", luainterop_ForceError },
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
