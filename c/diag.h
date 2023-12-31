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


//---------------- Public API ----------------------//

/// Diagnostic utility.
/// @param[in] l Internal lua state.
/// @param[in] info User info.
void diag_DumpStack(lua_State* l, const char* info);

/// Diagnostic utility.
/// @param[in] l Internal lua state.
/// @param[in] tbl_name User info.
void diag_DumpTable(lua_State* l, const char* tbl_name);

/// Check/log stack size.
/// @param[in] l Internal lua state.
/// @param[in] expected What it should be.
void diag_EvalStack(lua_State* l, int expected);

/// Convert a status to string.
/// @param[in] stat Status to examine.
/// @return String or NULL if not valid.
const char* diag_LuaStatusToString(int stat);

#endif // C_DIAG_H
