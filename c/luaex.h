#ifndef LUAEX_H
#define LUAEX_H

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

// TODO3 Add tableex type support similar to LuaEx.cs/TableEx.cs. structinator?

typedef struct tableex
{
    int something;
} tableex;

// Push a table onto lua stack.
void luaex_pushtableex(lua_State* l, tableex* tbl);

// Make a TableEx from the lua table on the top of the stack.
// Like other "to" functions except also does the pop.
tableex* luaex_totableex(lua_State* l, int ind);

// Interface to 'lua_pcall', which sets appropriate message function and C-signal handler. Used to run all chunks.
// Returns lua status.
int luaex_docall(lua_State* l, int num_args, int num_ret);


#endif // LUAEX_H
