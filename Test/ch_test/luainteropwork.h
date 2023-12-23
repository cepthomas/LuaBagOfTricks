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

bool luainteropwork_MyLuaFunc3(double arg_one);

double luainteropwork_FuncWithNoArgs();

#endif // LUAINTEROP_WORK_H
