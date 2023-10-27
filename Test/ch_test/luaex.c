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
#include "luaex.h"
#include "luainterop.h"

tableex _t;

void lua_pushtableex(lua_State* l, tableex* tbl)
{
}

tableex* lua_totableex(lua_State* l, int ind)
{
    return &_t;
}

int luaL_docall(lua_State* l, int num_args, int num_ret)
{
    return 0;
}
