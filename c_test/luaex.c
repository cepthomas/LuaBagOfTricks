
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"

// TODO2 Create C version of the C# core.

bool lua_LuaError(lua_State* l, const char* fn, int line, int err, const char* format, ...)
{
    return false;
}


void lua_pushtableex(lua_State* l, lua_tableex* tbl)
{

}

lua_tableex t;
lua_tableex* lua_totableex(lua_State* l, int ind)
{
    return &t;
}


int luaL_docall(lua_State* l, int num_args, int num_ret) // optionally throws
{
    return 0;
}
