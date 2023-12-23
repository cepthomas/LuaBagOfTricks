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
tableex _t;

// Capture error stack trace Message handler used to run all chunks.
static int p_handler(lua_State* L);


//--------------------------------------------------------//
void luaex_pushtableex(lua_State* l, tableex* tbl)
{
}

//--------------------------------------------------------//
tableex* luaex_totableex(lua_State* l, int ind)
{
    return &_t;
}

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
static int p_handler(lua_State* L)
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



// /// <summary>
// /// Loads and runs the given file.
// /// </summary>
// /// <param name="file"></param>
// /// <returns>Returns false if there are no errors or true in case of errors.</returns>
// public bool DoFile(string file) TODO2
// {
//     bool err;
//     LuaStatus lstat = LoadFile(file);
//     err = EvalLuaStatus(lstat);
//     lstat = DoCall(0, LUA_MULTRET);
//     err |= EvalLuaStatus(lstat);
//     return err;
// }
// /// <summary>
// /// Loads and runs the given string.
// /// </summary>
// /// <param name="chunk"></param>
// /// <returns>Returns false if there are no errors or true in case of errors.</returns>
// public bool DoString(string chunk) TODO2
// {
//     bool err;
//     LuaStatus lstat = LoadString(chunk);
//     err = EvalLuaStatus(lstat);
//     lstat = DoCall(0, LUA_MULTRET);
//     err |= EvalLuaStatus(lstat);
//     return err;
// }

