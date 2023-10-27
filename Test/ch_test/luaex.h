#ifndef LUAEX_H
#define LUAEX_H

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


// TODO need implementation for these.

typedef struct tableex {
  int something;
} tableex;

void lua_pushtableex(lua_State* l, tableex* tbl);

tableex* lua_totableex(lua_State* l, int ind);

int luaL_docall(lua_State* l, int num_args, int num_ret);

#endif // LUAEX_H
