#include <stdarg.h>
#include <string.h>
#include "logger.h"
#include "diag.h"


//--------------------- Defs -----------------------------//

#define BUFF_LEN 100

//------------------- Privates ---------------------------//


//--------------------------------------------------------//
int diag_DumpStack(lua_State* L, const char* info)
{
    static char buff[BUFF_LEN];

    LOG_DEBUG("Dump stack:%s (L:%p)", info, L);

    for(int i = lua_gettop(L); i >= 1; i--)
    {
        int t = lua_type(L, i);

        switch(t)
        {
            case LUA_TSTRING:
                snprintf(buff, BUFF_LEN-1, "index:%d string:%s ", i, lua_tostring(L, i));
                break;
            case LUA_TBOOLEAN:
                snprintf(buff, BUFF_LEN-1, "index:%d bool:%s ", i, lua_toboolean(L, i) ? "true" : "false");
                break;
            case LUA_TNUMBER:
                snprintf(buff, BUFF_LEN-1, "index:%d number:%g ", i, lua_tonumber(L, i));
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
                snprintf(buff, BUFF_LEN-1, "index:%d %s:%p ", i, lua_typename(L, t), lua_topointer(L, i));
                break;
            default:
                snprintf(buff, BUFF_LEN-1, "index:%d type:%d", i, t);
                break;
        }
    
        LOG_DEBUG("    %s", buff);
    }

    return 0;
}

//--------------------------------------------------------//
int diag_DumpTable(lua_State* L, const char* tbl_name)
{
    LOG_DEBUG("table:%s", tbl_name);

    // Put a nil key on stack.
    lua_pushnil(L);

    // key(-1) is replaced by the next key(-1) in table(-2).
    while (lua_next(L, -2) != 0)
    {
        // Get key(-2) name.
        const char* kname = lua_tostring(L, -2);

        // Get type of value(-1).
        const char* type = luaL_typename(L, -1);
        LOG_DEBUG("    %s=%s", kname, type);

        // Remove value(-1), now key on top at(-1).
        lua_pop(L, 1);
    }
    
    return 0;
}

//--------------------------------------------------------//
void diag_EvalStack(lua_State* L, int expected)
{
    int num = lua_gettop(L);
    if (num != expected)
    {
        LOG_DEBUG("Expected %d stack but is %d", expected, num);
    }
}


// //--------------------------------------------------------//
// void diag_LuaError(lua_State* L, const char* fn, int line, int err, const char* msg) TODO1 consolidate errors
// {
//     static char buff[BUFF_LEN];

//     if (err >= LUA_ERRRUN && err <= LUA_ERRFILE)
//     {
//         LOG_DEBUG("%s:%s", diag_LuaErrToString(err), msg);

//         // Dump trace.
//         luaL_traceback(L, L, NULL, 1);
//         snprintf(buff, BUFF_LEN-1, "%s | %s | %s", lua_tostring(L, -1), lua_tostring(L, -2), lua_tostring(L, -3));
//         LOG_DEBUG(buff);

//         lua_error(L); // never returns
//     }
// }

// public bool EvalLuaStatus(LuaStatus lstat, [CallerFilePath] string file = "", [CallerLineNumber] int line = 0)
// {
//     bool hasError = false;
//     if (lstat >= LuaStatus.ErrRun)
//     {
//         hasError = true;
//         // Get error message on stack.
//         string s;
//         if (GetTop() > 0)
//         {
//             s = ToString(-1)!.Trim();
//             Pop(1); // remove
//         }
//         else
//         {
//             s = "No error message!!!";
//         }
//         var serror = $"{file}({line}) [{lstat}]: {s}";
//     }
//     return hasError;
// }


//--------------------------------------------------------//
const char* diag_LuaErrToString(int err)
{
    const char* serr = "UNKNOWN";
    switch(err)
    {
        case LUA_OK: serr = "OK"; break;
        case LUA_YIELD: serr = "YIELD"; break;
        case LUA_ERRRUN: serr = "ERRRUN"; break;
        case LUA_ERRSYNTAX: serr = "ERRSYNTAX"; break; // syntax error during pre-compilation
        case LUA_ERRMEM: serr = "ERRMEM"; break; // memory allocation error
        case LUA_ERRERR: serr = "ERRERR"; break; // error while running the error handler function
        case LUA_ERRFILE: serr = "ERRFILE"; break; // couldn't open the given file
    }
    return serr;
}
