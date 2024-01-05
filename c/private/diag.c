#include <stdarg.h>
#include <string.h>
#include "diag.h"


#define BUFF_LEN 100


//--------------------------------------------------------//
void diag_DumpStack(lua_State* l, const char* info)
{
    static char buff[BUFF_LEN];

    printf("Dump stack:%s (l:%p)", info, l);

    for(int i = lua_gettop(l); i >= 1; i--)
    {
        int t = lua_type(l, i);

        switch(t)
        {
            case LUA_TSTRING:
                snprintf(buff, BUFF_LEN-1, "index:%d string:%s ", i, lua_tostring(l, i));
                break;
            case LUA_TBOOLEAN:
                snprintf(buff, BUFF_LEN-1, "index:%d bool:%s ", i, lua_toboolean(l, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:
                snprintf(buff, BUFF_LEN-1, "index:%d number:%g ", i, lua_tonumber(l, i));
                break;
            case LUA_TNIL:
                snprintf(buff, BUFF_LEN-1, "index:%d nil", i);
                break;
            case LUA_TNONE:
                snprintf(buff, BUFF_LEN-1, "index:%d none", i);
                break;
            case LUA_TFUNCTION:
            case LUA_TTABLE:
            case LUA_TTHREAD:
            case LUA_TUSERDATA:
            case LUA_TLIGHTUSERDATA:
                snprintf(buff, BUFF_LEN-1, "index:%d %s:%p ", i, lua_typename(l, t), lua_topointer(l, i));
                break;
            default:
                snprintf(buff, BUFF_LEN-1, "index:%d type:%d", i, t);
                break;
        }
    
        printf("    %s", buff);
    }
}

//--------------------------------------------------------//
void diag_DumpTable(lua_State* l, const char* tbl_name)
{
    printf("table:%s", tbl_name);

    // Put a nil key on stack.
    lua_pushnil(l);

    // key(-1) is replaced by the next key(-1) in table(-2).
    while (lua_next(l, -2) != 0)
    {
        // Get key(-2) name.
        const char* kname = lua_tostring(l, -2);

        // Get type of value(-1).
        const char* type = luaL_typename(l, -1);
        printf("    %s=%s", kname, type);

        // Remove value(-1), now key on top at(-1).
        lua_pop(l, 1);
    }
}

//--------------------------------------------------------//
void diag_EvalStack(lua_State* l, int expected)
{
    int num = lua_gettop(l);
    if (num != expected)
    {
        printf("Expected %d stack but is %d", expected, num);
    }
}

//--------------------------------------------------------//
const char* diag_LuaStatusToString(int stat)
{
    const char* sstat = NULL;
    switch(stat)
    {
        case LUA_OK: sstat = "LUA_OK"; break;
        case LUA_YIELD: sstat = "LUA_YIELD"; break;
        case LUA_ERRRUN: sstat = "LUA_ERRRUN"; break;
        case LUA_ERRSYNTAX: sstat = "LUA_ERRSYNTAX"; break; // syntax error during pre-compilation
        case LUA_ERRMEM: sstat = "LUA_ERRMEM"; break; // memory allocation error
        case LUA_ERRERR: sstat = "LUA_ERRERR"; break; // error while running the error handler function
        case LUA_ERRFILE: sstat = "LUA_ERRFILE"; break; // couldn't open the given file
        default: break; // nothing for now.
    }
    return sstat;
}
