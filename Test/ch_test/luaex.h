
#ifndef LUAEX_H
#define LUAEX_H

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


//------------------ framework provides this -----------------//

// tableex implementation.
typedef struct tableex {
  int something;
} tableex;

void lua_pushtableex(lua_State* l, tableex* tbl);

tableex* lua_totableex(lua_State* l, int ind);

int luaL_docall(lua_State* l, int num_args, int num_ret);



// // Calls luaL_error() so this never returns.
// bool lua_LuaError(lua_State* l, const char* fn, int line, int err, const char* format, ...);

// // Ditto.
// #define ErrorHandler(l, err, fmt, ...)  return lua_LuaError(l, __FILE__, __LINE__, err, fmt, ##__VA_ARGS__);


// int luaL_error (lua_State *L, const char *fmt, ...);
// Raises an error. The error message format is given by fmt plus any extra arguments, following the same rules of lua_pushfstring.
// It also adds at the beginning of the message the file name and the line number where the error occurred, if this information is available.
// This function never returns, but it is an idiom to use it in C functions as return luaL_error(args).

#endif // LUAEX_H
