#ifndef INTEROP_H
#define INTEROP_H

// #include <stdlib.h>
// #include <stdio.h>
// #include <stdarg.h>
// #include <stdbool.h>
// #include <stdint.h>
// #include <string.h>
// #include <float.h>
// #include <errno.h>
// #include <math.h>
// #include "lua.h"
// #include "lualib.h"
// #include "lauxlib.h"

//------------------ generator creates --------------------//

void interop_Load(lua_State* l);

lua_tableex* interop_HostCallLua(lua_State* l, char* arg1, int arg2, lua_tableex* arg3);

double interop_LuaCallHost_DoWork(int arg1, const char* arg2);

#endif // INTEROP_H
