#ifndef C_DIAG_H
#define C_DIAG_H

#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "logger.h"



//----------------------- Diagnostics -----------------------------//

// Diagnostic utility.
int diag_DumpStack(lua_State* L, const char* info);

// Diagnostic utility.
int diag_DumpTable(lua_State* L, const char* tbl_name);

// // Diagnostic utility.
// void diag_LuaError(lua_State* L, const char* fn, int line, int err, const char* msg);

// Check/log stack size.
void diag_EvalStack(lua_State* L, int expected);

// Make it readable.
const char* diag_LuaErrToString(int err);

// #define EVAL_STACK(L, expected) {     int num = lua_gettop(L);     if (num != expected)     {         LOG_DEBUG("Expected %d stack but is %d", expected, num);     } }

// // Helper macro to check then handle error.
// #define CHK_LUA_ERROR(L, err, msg)  if(err >= LUA_ERRRUN) { diag_LuaError(L, __FILE__, __LINE__, err, msg); }

//----------------------- Utils -----------------------------//

// // Interface to lua_pcall, but sets appropriate message function and C-signal handler. Used to run all chunks.
// int diag_DoCall(lua_State* L, int narg, int nres);



#endif // C_DIAG_H
