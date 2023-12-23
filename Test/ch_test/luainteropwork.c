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

bool luainteropwork_MyLuaFunc3(double arg_one)
{
    return arg_one > 100.0;
}

double luainteropwork_FuncWithNoArgs()
{
    return 123.4;
}
