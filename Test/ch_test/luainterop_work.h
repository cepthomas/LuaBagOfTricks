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

// Declaration of work functions.

bool luainterop_MyLuaFunc3Work(double arg_one);

double luainterop_FuncWithNoArgsWork();

#endif // LUAINTEROP_WORK_H
