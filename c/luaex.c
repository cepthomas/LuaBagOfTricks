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


//--------------------------------------------------------//

// Capture error stack trace Message handler used to run all chunks.
static int p_handler(lua_State* l);

//--------------------------------------------------------//
int luaex_docall(lua_State* l, int narg, int nres)
{
    int lstat = LUA_OK;
    int fbase = lua_gettop(l) - narg;  // function index
    lua_pushcfunction(l, p_handler);  // push message handler
    // put it under function and args  Insert(fbase);
    lua_rotate(l, fbase, 1);
    lstat = lua_pcall(l, narg, nres, fbase);
    // remove message handler from the stack NativeMethods.  Remove(fbase);
    lua_rotate(l, fbase, -1);
    lua_pop(l, 1);
    return lstat;
}

//--------------------------------------------------------//
// Capture error stack trace Message handler used to run all chunks.
static int p_handler(lua_State* l)
{
    char* msg = lua_tostring(l, 1);
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
void luaex_pushtableex(lua_State* l, tableex* tbl)
{
}

//--------------------------------------------------------//
tableex _t;
tableex* luaex_totableex(lua_State* l, int ind)
{
    return &_t;
}
