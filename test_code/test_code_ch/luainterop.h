#ifndef LUAINTEROP_H
#define LUAINTEROP_H

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

#define INTEROP_BAD_FUNC_NAME 10
#define INTEROP_BAD_RET_TYPE  11

//---------------- Call lua functions from host -------------//

/// Lua export function: Tell me something good.
/// @param[in] l Internal lua state.
/// @param[in] arg_one some strings
/// @param[in] arg_two a nice integer
/// @param[in] arg_three 
/// @param[out] int* a returned thing
/// @return status
int luainterop_MyLuaFunc(lua_State* l, const char* arg_one, int arg_two, int arg_three, int* ret);

/// Lua export function: wooga wooga
/// @param[in] l Internal lua state.
/// @param[in] arg_one aaa bbb ccc
/// @param[out] double* a returned number
/// @return status
int luainterop_MyLuaFunc2(lua_State* l, bool arg_one, double* ret);

/// Lua export function: function with no args
/// @param[in] l Internal lua state.
/// @param[out] double* a returned number
/// @return status
int luainterop_NoArgsFunc(lua_State* l, double* ret);


//---------------- Work functions for lua call host -------------//

/// fooga
/// @param[in] arg_one kakakakaka
/// @return required return value
bool luainteropwork_MyLuaFunc3(double arg_one);

/// Func with no args
/// @return a returned thing
double luainteropwork_FuncWithNoArgs();

//---------------- Infrastructure ----------------------//

void luainterop_Load(lua_State* l);

#endif // LUAINTEROP_H
