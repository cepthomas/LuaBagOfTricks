#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"
#include "interop.h"

int main(int argc, char* argv[])
{
    // Maybe do something?
    
    return 0;
}

double interop_LuaCallHost_DoWork(int arg1, const char* arg2)
{
    return arg1 + strlen(arg2);
}
