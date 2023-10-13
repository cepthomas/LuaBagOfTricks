#ifndef INTEROP_H
#define INTEROP_H
// extra includes

//-------- generator creates from spec --------------------//

// --------------------------------------------------------------------------
// Description
// @param name type desc
// @return type desc
void interop_Load(lua_State* l);

// --------------------------------------------------------------------------
// Description
// @param name type desc
// @return type desc
lua_tableex* interop_HostCallLua(lua_State* l, char* arg1, int arg2, lua_tableex* arg3);

// --------------------------------------------------------------------------
// Description
// @param name type desc
// @return type desc
double interop_LuaCallHost_DoWork(int arg1, const char* arg2);

#endif // INTEROP_H
