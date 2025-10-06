#ifndef LUAEX_H
#define LUAEX_H

#include <stdbool.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


/// Interface to lua_pcall(). If error occurs the traceback is added to the stack. 
/// Used to run all function chunks. Modeled after docall(...).
/// @param[in] l Internal lua state.
/// @param[in] num_args Number of args.
/// @param[in] num_ret Number of return values.
/// @return LUA_STATUS
int luaex_docall(lua_State* l, int num_args, int num_ret);

/// Dump the lua stack contents.
/// @param l Lua state.
/// @param fout where to boss.
/// @param info Extra info.
int luaex_DumpStack(lua_State *l, FILE* fout, const char* info);

/// Dump the table at the top.
/// @param l Lua state.
/// @param fout where to boss.
/// @param name visual.
int luaex_DumpTable(lua_State* l, FILE* fout, const char* name);

/// Dump the lua globals.
/// @param l Lua state.
/// @param fout where to boss.
int luaex_DumpGlobals(lua_State* l, FILE* fout);

 /// Check stack.
 void luaex_EvalStack(lua_State* l, FILE* fout, int expected);

/// Safe convert a string to double with bounds checking.
/// @param[in] str to parse
/// @param[out] val answer
/// @param[in] min limit inclusive
/// @param[in] max limit inclusive
/// @return success
bool luaex_ParseDouble(const char* str, double* val, double min, double max);

/// Safe convert a string to int with bounds checking.
/// @param[in] str to parse
/// @param[out] val answer
/// @param[in] min limit inclusive
/// @param[in] max limit inclusive
/// @return success
bool luaex_ParseInt(const char* str, int* val, int min, int max);


#endif // LUAEX_H
