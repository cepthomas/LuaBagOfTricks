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

#define INTEROP_BAD_FUNC_NAME 10
#define INTEROP_BAD_RET_TYPE  11
#define MAX_STRING 100

//---------------- Call lua functions from host -------------//

/// Lua export function: Simple caalculations.
/// @param[in] l Internal lua state.
/// @param[in] op_one Operand 1.
/// @param[in] oper Operator: + - * /
/// @param[in] op_two Operand 2.
/// @param[out] double* The answer
/// @return status
int luainterop_Calculator(lua_State* l, double op_one, char* oper, double op_two, double* ret);

/// Lua export function: String to integer.
/// @param[in] l Internal lua state.
/// @param[in] day The day name.
/// @param[out] int* The answer.
/// @return status
int luainterop_DayOfWeek(lua_State* l, char* day, int* ret);

/// Lua export function: Function with no args.
/// @param[in] l Internal lua state.
/// @param[out] char** Day name.
/// @return status
int luainterop_FirstDay(lua_State* l, char** ret);

/// Lua export function: Function not implemented in script.
/// @param[in] l Internal lua state.
/// @param[out] bool* Required dummy return value.
/// @return status
int luainterop_InvalidFunc(lua_State* l, bool* ret);

/// Lua export function: Function argument type incorrect.
/// @param[in] l Internal lua state.
/// @param[in] arg1 The arg.
/// @param[out] bool* Required dummy return value.
/// @return status
int luainterop_InvalidArgType(lua_State* l, char* arg1, bool* ret);

/// Lua export function: Function return type incorrect.
/// @param[in] l Internal lua state.
/// @param[out] int* Required dummy return value.
/// @return status
int luainterop_InvalidRetType(lua_State* l, int* ret);

/// Lua export function: Function that calls error().
/// @param[in] l Internal lua state.
/// @param[in] flavor Tweak behavior.
/// @param[out] bool* Required dummy return value.
/// @return status
int luainterop_ErrorFunc(lua_State* l, int flavor, bool* ret);


//---------------- Work functions for lua call host -------------//

/// Record something for me.
/// @param[in] level Log level.
/// @param[in] msg What to log.
/// @return Required dummy return value.
bool luainteropwork_Log(int level, char* msg);

/// How hot are you?
/// @param[in] temp Temperature.
/// @return String environment.
char* luainteropwork_GetEnvironment(double temp);

/// Milliseconds.
/// @return The time.
int luainteropwork_GetTimestamp();

/// Raise an error from lua code.
/// @return Required dummy return value.
bool luainteropwork_ForceError();

//---------------- Infrastructure ----------------------//

void luainterop_Load(lua_State* l);

#endif // LUAINTEROP_H
