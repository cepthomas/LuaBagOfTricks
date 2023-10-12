
#ifndef LUAEX_H
#define LUAEX_H

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


//------------------ framework provides this -----------------//

// tableex implementation.
typedef struct lua_tableex {
  int something;
} lua_tableex;

void lua_pushtableex(lua_State* l, lua_tableex* tbl);

lua_tableex* lua_totableex(lua_State* l, int ind);

int luaL_docall(lua_State* l, int num_args, int num_ret);

// Calls luaL_error() so this never returns.
bool lua_LuaError(lua_State* l, const char* fn, int line, int err, const char* format, ...);
// Ditto.
#define ErrorHandler(l, err, fmt, ...)  return lua_LuaError(l, __FILE__, __LINE__, err, fmt, ##__VA_ARGS__);

#endif // LUAEX_H
