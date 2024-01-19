#ifndef LUAINTEROPWORK_H
#define LUAINTEROPWORK_H

///// Warning - this file is created by gen_interop.lua, do not edit. /////

#include "luainterop.h"

//---------------- Work functions for interop -------------//

/// fooga
/// @param[in] l Internal lua state.
/// @param[in] arg_one kakakakaka
/// @return required return value
bool luainteropwork_MyLuaFunc3(lua_State* l, double arg_one);

/// Func with no args
/// @param[in] l Internal lua state.
/// @return a returned thing
double luainteropwork_FuncWithNoArgs(lua_State* l);

#endif // LUAINTEROPWORK_H
