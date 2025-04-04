#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <float.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "luaex.h"

#define BUFF_LEN 300


//--------------------------------------------------------//
// Capture error stack.
static int _handler(lua_State* l)
{
    const char* msg = lua_tostring(l, 1);
    if (msg == NULL)  // is error object not a string?
    {
        // Does it have a metamethod that produces a string?
        if (luaL_callmeta(l, 1, "__tostring") && lua_type(l, -1) == LUA_TSTRING)
        {
            // that is the message
            return 1;
        }
        else
        {
            msg = "Error object is a not a string";
            lua_pushstring(l, msg);
        }
    }

    // Append and return a standard traceback.
    luaL_traceback(l, l, msg, 1);  
    return 1;
}


//--------------------------------------------------------//
int luaex_docall(lua_State* l, int narg, int nres)
{
    int lstat = LUA_OK;
    int fbase = lua_gettop(l) - narg;  // function index
    lua_pushcfunction(l, _handler);  // push message handler
    // put it under function and args  Insert(fbase);
    lua_rotate(l, fbase, 1);
    lstat = lua_pcall(l, narg, nres, fbase); // nres always 1
    // remove message handler from the stack NativeMethods. Remove(fbase);
    lua_rotate(l, fbase, -1);
    lua_pop(l, 1);
    return lstat;
}


//--------------------------------------------------------//
int luaex_DumpStack(lua_State* l, FILE* fout, const char* info)
{
    static char buff[BUFF_LEN];

    fprintf(fout, "Dump stack:%s (L:%p)\n", info, l);

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
    
        fprintf(fout, "   %s\n", buff);
    }

    return 0;
}

//--------------------------------------------------------//
const char* luaex_LuaStatusToString(int stat)
{
    const char* sstat = "UNKNOWN";
    switch(stat)
    {
        case LUA_OK: sstat = "LUA_OK"; break;
        case LUA_YIELD: sstat = "LUA_YIELD"; break;
        case LUA_ERRRUN: sstat = "LUA_ERRRUN"; break;
        case LUA_ERRSYNTAX: sstat = "LUA_ERRSYNTAX"; break; // syntax error during pre-compilation
        case LUA_ERRMEM: sstat = "LUA_ERRMEM"; break; // memory allocation error
        case LUA_ERRERR: sstat = "LUA_ERRERR"; break; // error while running the error handler function
        case LUA_ERRFILE: sstat = "LUA_ERRFILE"; break; // couldn't open the given file
        default: break; // nothing else for now.
    }
    return sstat;
}

//--------------------------------------------------------//
int luaex_DumpTable(lua_State* l, FILE* fout, const char* name) // TODOF make recursive like lua dump_table()?
{
    fprintf(fout, "%s\n", name);

    // Put a nil key on stack.
    lua_pushnil(l);

    // key(-1) is replaced by the next key(-1) in table(-2).
    while (lua_next(l, -2) != 0)
    {
        // Get key(-2) name.
        const char* name = lua_tostring(l, -2);

        // Get type of value(-1).
        const char* type = luaL_typename(l, -1);

        // Get value(-1).
        const char* sval = luaL_tolstring(l, -1, NULL);
        fprintf(fout, "   %s:%s(%s)\n", name, sval, type);
        // Remove the sval from the stack.
        lua_pop(l, 1);

        // Remove value(-1), now key on top at(-1).
        lua_pop(l, 1);
    }
    
    return 0;
}

//--------------------------------------------------------//
int luaex_DumpGlobals(lua_State* l, FILE* fout)
{
    // Get global table.
    lua_pushglobaltable(l);

    luaex_DumpTable(l, fout, "GLOBALS");

    // Remove global table(-1).
    lua_pop(l,1);

    return 0;
}

 //--------------------------------------------------------//
 void luaex_EvalStack(lua_State* l, FILE* fout, int expected)
 {
     int num = lua_gettop(l);
     if (num != expected)
     {
         fprintf(fout, "Expected %d stack but is %d\n", expected, num);
     }
 }

//--------------------------------------------------------//
bool luaex_ParseDouble(const char* str, double* val, double min, double max)
{
    bool valid = true;
    char* p;

    errno = 0;
    *val = strtof(str, &p);
    if (errno == ERANGE)
    {
        // Mag is too large.
        valid = false;
    }
    else if (p == str)
    {
        // Bad string.
        valid = false;
    }
    else if (*val < min || *val > max)
    {
        // Out of range.
        valid = false;
    }

    return valid;
}

//--------------------------------------------------------//
bool luaex_ParseInt(const char* str, int* val, int min, int max)
{
    bool valid = true;
    char* p;

    errno = 0;
    *val = strtol(str, &p, 10);
    if (errno == ERANGE)
    {
        // Mag is too large.
        valid = false;
    }
    else if (p == str)
    {
        // Bad string.
        valid = false;
    }
    else if (*val < min || *val > max)
    {
        // Out of range.
        valid = false;
    }

    return valid;
}









//--------------------------------------------------------//
void luaex_pushtableex(lua_State* l, tableex_t* tbl)
{
}

//--------------------------------------------------------//
tableex_t _t;
tableex_t* luaex_totableex(lua_State* l, int ind)
{
    return &_t;
}

