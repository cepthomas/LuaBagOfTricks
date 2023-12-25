#include <stdarg.h>
#include <string.h>
#include "logger.h"
#include "diag.h"


//--------------------- Defs -----------------------------//

#define BUFF_LEN 100

//------------------- Privates ---------------------------//


//--------------------------------------------------------//
int diag_DumpStack(lua_State* l, const char* info)
{
    static char buff[BUFF_LEN];

    logger_Log(LVL_DEBUG, "Dump stack:%s (l:%p)", info, l);

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
    
        logger_Log(LVL_DEBUG, "    %s", buff);
    }

    return 0;
}

//--------------------------------------------------------//
int diag_DumpTable(lua_State* l, const char* tbl_name)
{
    logger_Log(LVL_DEBUG, "table:%s", tbl_name);

    // Put a nil key on stack.
    lua_pushnil(l);

    // key(-1) is replaced by the next key(-1) in table(-2).
    while (lua_next(l, -2) != 0)
    {
        // Get key(-2) name.
        const char* kname = lua_tostring(l, -2);

        // Get type of value(-1).
        const char* type = luaL_typename(l, -1);
        logger_Log(LVL_DEBUG, "    %s=%s", kname, type);

        // Remove value(-1), now key on top at(-1).
        lua_pop(l, 1);
    }
    
    return 0;
}

//--------------------------------------------------------//
void diag_EvalStack(lua_State* l, int expected)
{
    int num = lua_gettop(l);
    if (num != expected)
    {
        logger_Log(LVL_DEBUG, "Expected %d stack but is %d", expected, num);
    }
}

//--------------------------------------------------------//
const char* diag_LuaStatusToString(int err)
{
    const char* serr = NULL;
    switch(err)
    {
        case LUA_OK: serr = "LUA_OK"; break;
        case LUA_YIELD: serr = "LUA_YIELD"; break;
        case LUA_ERRRUN: serr = "LUA_ERRRUN"; break;
        case LUA_ERRSYNTAX: serr = "LUA_ERRSYNTAX"; break; // syntax error during pre-compilation
        case LUA_ERRMEM: serr = "LUA_ERRMEM"; break; // memory allocation error
        case LUA_ERRERR: serr = "LUA_ERRERR"; break; // error while running the error handler function
        case LUA_ERRFILE: serr = "LUA_ERRFILE"; break; // couldn't open the given file
        default: break; // nothing for now.
    }
    return serr;
}
