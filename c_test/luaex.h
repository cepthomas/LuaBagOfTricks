
#ifndef LUAEX_H
#define LUAEX_H

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


//------------------ application provides -----------------//

typedef struct lua_tableex {
  int something;
} lua_tableex;

bool lua_LuaError(lua_State* l, const char* fn, int line, int err, const char* format, ...);

#define ErrorHandler(l, err, fmt, ...)  if (err >= LUA_ERRRUN) { return lua_LuaError(l, __FILE__, __LINE__, err, fmt, ##__VA_ARGS__); }

void lua_pushtableex(lua_State* l, lua_tableex* tbl);

lua_tableex* lua_totableex(lua_State* l, int ind);

int luaL_docall(lua_State* l, int num_args, int num_ret);

#endif // LUAEX_H
