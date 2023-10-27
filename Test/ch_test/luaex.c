
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

// bool lua_LuaError(lua_State* l, const char* fn, int line, int err, const char* format, ...)
// {
//     #define BUFF_LEN 100
//     char buff[BUFF_LEN];

//     va_list args;
//     va_start(args, format);
//     vsnprintf(buff, BUFF_LEN - 1, format, args);
//     va_end(args);

//     luaL_error(l, "Error %d! %s(%d) %s", err, fn, line, buff);
//     // never returns

//     return false;
// }
