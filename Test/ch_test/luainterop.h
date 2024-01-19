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

//---------------- Call lua functions from host -------------//

/// Lua export function: Tell me something good.
/// @param[in] l Internal lua state.
/// @param[in] arg_one some strings
/// @param[in] arg_two a nice integer
/// @param[in] arg_three 
/// @return int a returned thing
int luainterop_MyLuaFunc(lua_State* l, const char* arg_one, int arg_two, int arg_three);

/// Lua export function: wooga wooga
/// @param[in] l Internal lua state.
/// @param[in] arg_one aaa bbb ccc
/// @return double a returned number
double luainterop_MyLuaFunc2(lua_State* l, bool arg_one);

/// Lua export function: function with no args
/// @param[in] l Internal lua state.
/// @return double a returned number
double luainterop_NoArgsFunc(lua_State* l);


///// Infrastructure.
void luainterop_Load(lua_State* l);

#endif // LUAINTEROP_H
