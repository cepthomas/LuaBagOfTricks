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
#include "luainterop.h"

tableex _t;

// Capture error stack trace Message handler used to run all chunks.
static int p_MsgHandler(lua_State* L);


void lua_pushtableex(lua_State* l, tableex* tbl)
{
}

tableex* lua_totableex(lua_State* l, int ind)
{
    return &_t;
}

int luaL_docall(lua_State* l, int narg, int nres)
{
    int lstat = LUA_OK;
    int fbase = lua_gettop(l) - narg;  // function index
    lua_pushcfunction(l, p_MsgHandler);  // push message handler
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
static int p_MsgHandler(lua_State* L)
{
    char* msg = lua_tostring(L, 1);
    if (msg == NULL)  // is error object not a string?
    {
        // Does it have a metamethod that produces a string?
        if (luaL_callmeta(L, 1, "__tostring") && lua_type(L, -1) == LUA_TSTRING)
        {
            // that is the message
            return 1;
        }
        else
        {
            msg = "Error object is a not a string";
            lua_pushstring(L, msg);
        }
    }

    // Append and return a standard traceback.
    luaL_traceback(L, L, msg, 1);  
    return 1;
}
