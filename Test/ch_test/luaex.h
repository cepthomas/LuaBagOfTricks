#ifndef LUAEX_H
#define LUAEX_H

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


// TODO Eventually need implementation for these, like LuaEx.cs and TableEx.cs.

typedef struct tableex
{
  int something;
} tableex;

// Push a table onto lua stack.
void lua_pushtableex(lua_State* l, tableex* tbl);

// Make a TableEx from the lua table on the top of the stack.
// Like other "to" functions except also does the pop.
tableex* lua_totableex(lua_State* l, int ind);

// Interface to 'lua_pcall', which sets appropriate message function and C-signal handler. Used to run all chunks.
// @param[in] l 
// @param[in] num_args 
// @param[in] num_ret 
// @return status
int luaL_docall(lua_State* l, int num_args, int num_ret);


#endif // LUAEX_H
