#include <cstdio>
#include <cstring>
#include <fstream>
#include "pnut.h"

extern "C"
{
#include <windows.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luautils.h"
#include "luainterop.h"
}


// The main Lua thread.
static lua_State* _l;
static int _timestamp = 1000;
static char _last_log[500];

// Top level error handler for nebulua status.
static const char* CheckStatus(int stat);


/////////////////////////////////////////////////////////////////////////////
UT_SUITE(INTEROP_LOAD, "Test load and unload lua script.")
{
    int stat;
    const char* slua_error;

    // Init internal stuff.
    _l = luaL_newstate();
     //luautils_EvalStack(_l, stdout, 0);

    //FILE* fp = fopen("_here .txt", "w");
    //fprintf(fp, "here");

    // Load std libraries.
    luaL_openlibs(_l);

    // Load host funcs into lua space. This table gets pushed on the stack and into globals.
    luainterop_Load(_l);

    // Pop the table off the stack as it interferes with calling the module functions.
    lua_pop(_l, 1);

    // Load the script file.
    // Pushes the compiled chunk as a Lua function on top of the stack or pushes an error message.
    const char* fn = "";

    // Try to load/compile non-existent file.
    fn = "bad_script_file_name.lua";
    stat = luaL_loadfile(_l, fn);
    UT_EQUAL(stat, LUA_ERRFILE);
    slua_error = CheckStatus(stat);
    UT_NOT_NULL(slua_error);
    UT_STR_CONTAINS(slua_error, "cannot open bad_script_file_name.lua: No such file or directory");

    fn = "script_load_error.lua";
    stat = luaL_loadfile(_l, fn);
    UT_EQUAL(stat, LUA_ERRSYNTAX);
    slua_error = CheckStatus(stat);
    UT_NOT_NULL(slua_error);
    UT_STR_CONTAINS(slua_error, "syntax error near 'ts'");

    fn = "script_main.lua";
    stat = luaL_loadfile(_l, fn);
    UT_EQUAL(stat, LUA_OK);
    slua_error = CheckStatus(stat);
    UT_NULL(slua_error);
    // Should be ok.

    //luautils_DumpGlobals(_l, stdout);

    UT_INFO("Fini!", "");
    lua_close(_l);

    return 0;
}    


/////////////////////////////////////////////////////////////////////////////
UT_SUITE(INTEROP_EXEC, "Test execute script via luainterop.")
{
    int stat;
    const char* slua_error;
    const char* sinterop_error;

    // Init internal stuff.
    _l = luaL_newstate();
     //luautils_EvalStack(_l, stdout, 0);

    // Load std libraries.
    luaL_openlibs(_l);

    // Load host funcs into lua space. This table gets pushed on the stack and into globals.
    luainterop_Load(_l);

    // Pop the table off the stack as it interferes with calling the module functions.
    lua_pop(_l, 1);

    // Load the script file.
    // Pushes the compiled chunk as a Lua function on top of the stack or pushes an error message.
    const char* fn = "";

    fn = "script_main.lua";
    stat = luaL_loadfile(_l, fn);
    UT_EQUAL(stat, LUA_OK);
    slua_error = CheckStatus(stat);
    UT_NULL(slua_error);
    // Should be ok.

    // If stat is ok, run the script to init everything.
    stat = lua_pcall(_l, 0, LUA_MULTRET, 0);
    UT_EQUAL(stat, LUA_OK);
    slua_error = CheckStatus(stat);
    UT_NULL(slua_error);
    // Should be ok.

    // This should be set by the script execution.
    UT_STR_EQUAL(_last_log, "Log LVL1 I know this: ts:1100 env:Temperature is 27.3 degrees");

    //luautils_DumpGlobals(_l, stdout);

    // Call to the script.
    char op[] = {"*"};
    double answer = luainterop_Calculator(_l, 12.96, op, 3.15);
    sinterop_error = luainterop_Error();
    UT_NULL(sinterop_error);
    UT_CLOSE(answer, 40.824, 0.001);

    char day[] = { "Moonday" };
    int daynum = luainterop_DayOfWeek(_l, day);
    sinterop_error = luainterop_Error();
    UT_NULL(sinterop_error);
    UT_EQUAL(daynum, 3);

    const char* dayname = luainterop_FirstDay(_l);
    sinterop_error = luainterop_Error();
    UT_NULL(sinterop_error);
    UT_STR_EQUAL(dayname, "Hamday");

    int dummy = luainterop_InvalidFunc(_l);
    sinterop_error = luainterop_Error();
    UT_NOT_NULL(sinterop_error);
    UT_STR_CONTAINS(sinterop_error, "Bad function name: invalid_func()");

    char arg[] = { "abc" };
    dummy = luainterop_InvalidArgType(_l, arg);
    sinterop_error = luainterop_Error();
    UT_NOT_NULL(sinterop_error);
    UT_STR_CONTAINS(sinterop_error, "attempt to add a 'string' with a 'number'");

    dummy = luainterop_InvalidRetType(_l);
    sinterop_error = luainterop_Error();
    UT_NOT_NULL(sinterop_error);
    UT_STR_CONTAINS(sinterop_error, "Bad return type for invalid_ret_type(): should be integer");

    // Force error - C calls lua which calls error(). This is fatal.
    dummy = luainterop_ErrorFunc(_l, 1);
    sinterop_error = luainterop_Error();
    UT_NOT_NULL(sinterop_error);
    UT_STR_CONTAINS(sinterop_error, "user_lua_func3() raises error()");

    // Force error - C calls lua which calls C which calls luaL_error().
    dummy = luainterop_ErrorFunc(_l, 2);
    sinterop_error = luainterop_Error();
    UT_NOT_NULL(sinterop_error);
    UT_STR_CONTAINS(sinterop_error, "Let's blow something up in lua");

    // Try to call optional function.
    dummy = luainterop_OptionalFunc(_l);
    sinterop_error = luainterop_Error();
    UT_NULL(sinterop_error);

    // Done.
    UT_INFO("Fini!", "");
    lua_close(_l);

    return 0;
}    



//---------------- Call host functions from Lua - work functions -------------//

//--------------------------------------------------------//
int luainteropwork_GetTimestamp(lua_State* l)
{
    _timestamp += 100;
    return _timestamp;
}

//--------------------------------------------------------//
bool luainteropwork_Log(lua_State* l, int level, const char* msg)
{
    snprintf(_last_log, sizeof(_last_log) - 1, "Log LVL%d %s", level, msg);
    return true;
}

//--------------------------------------------------------//
const char* luainteropwork_GetEnvironment(lua_State* l, double temp)
{
    static char buff[50];
    snprintf(buff, sizeof(buff) - 1, "Temperature is %.1f degrees", temp);
    return buff;
}

//--------------------------------------------------------//
bool luainteropwork_ForceError(lua_State* l)
{
    luaL_error(_l, "Let's blow something up in lua");
    return true;
}


//---------------- Test helpers -------------//


//--------------------------------------------------------//
const char* CheckStatus(int stat)
{
    static char buff[500];
    char* sret = NULL;

    if (stat >= LUA_ERRRUN)
    {
        // Error message.
        const char* errmsg = NULL;
        if (stat <= LUA_ERRFILE && lua_gettop(_l) > 0) // internal lua error - get error message on stack if provided.
        {
            errmsg = lua_tostring(_l, -1);
            strncpy(buff, errmsg, sizeof(buff) - 1);
            sret = buff;
        }
    }

    return sret;
}
