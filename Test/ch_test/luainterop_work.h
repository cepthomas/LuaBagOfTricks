#ifndef LUAINTEROP_WORK_H
#define LUAINTEROP_WORK_H

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
#include "luainterop.h"

//------------------ generator creates --------------------//


void interop_Load(lua_State* l);

tableex* interop_DoOperation(lua_State* l, char* arg1, int arg2, tableex* arg3);

double interop_LuaCallHost_DoWork(int arg1, const char* arg2);

#endif // LUAINTEROP_WORK_H
