#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <float.h>
#include <errno.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"
#include "luainterop.h"

// Definition of work functions.

bool luainterop_MyLuaFunc3Work(double arg_one)
{
    return arg_one > 100.0;
}

double luainterop_FuncWithNoArgsWork()
{
    return 123.4;
}
