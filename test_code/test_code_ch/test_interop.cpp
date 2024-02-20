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
#include "logger.h"
}


// The main Lua thread.
static lua_State* _l;
static int _timestamp = 1000;
static char _last_log[500];
static char _last_error[500];

// Point these where you like.
static FILE* _log_out = stdout;
static FILE* _error_out = stdout;

// Top level error handler for nebulua status.
static bool _EvalStatus(int stat, int line, const char* format, ...);


/////////////////////////////////////////////////////////////////////////////
UT_SUITE(INTEROP_MAIN, "Test luainterop.")
{
    int stat;
    bool ok = false;
    int iret = 0;
    double dret = 0;
    bool bret = false;
    const char* sret = NULL;

    // Init system before running tests.
    _log_out = fopen("_log.txt", "w");
    logger_Init(_log_out);

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

    // Try to load non-existent file.
    fn = "bad_script_file_name.lua";
    stat = luaL_loadfile(_l, fn);
    ok = _EvalStatus(stat, __LINE__, "load script file failed: %s", fn);
    UT_FALSE(ok);
    UT_STR_EQUAL(_last_error, "LUA_ERRFILE load script file failed: bad_script_file_name.lua\ncannot open bad_script_file_name.lua: No such file or directory");

    fn = "C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\test_code\\test_code_ch\\script6.lua";
    stat = luaL_loadfile(_l, fn);
    ok = _EvalStatus(stat, __LINE__, "load script file failed: %s", fn);
    UT_FALSE(ok);
    UT_STR_CONTAINS(_last_error, "LUA_ERRSYNTAX load script file failed: C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\test_code\\test_code_ch\\script6.lua");

    fn = "C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\test_code\\test_code_ch\\script7.lua";
    stat = luaL_loadfile(_l, fn);
    ok = _EvalStatus(stat, __LINE__, "load script file failed: %s", fn);
    UT_TRUE(ok);
    UT_STR_EQUAL(_last_error, "No error");
    // Should be ok.

    // If stat is ok, run the script to init everything.
    stat = lua_pcall(_l, 0, LUA_MULTRET, 0);
    ok = _EvalStatus(stat, __LINE__, "execute script failed: %s", fn);
    UT_TRUE(ok);
    UT_STR_EQUAL(_last_error, "No error");
    // Should be ok.

    // This should be set by the script execution.
    //printf(">>>%s\n", _last_log);
    UT_STR_EQUAL(_last_log, "Log LVL1 I know this: ts:1100 env:Temperature is 27.3 degrees");

    //luautils_DumpGlobals(_l, stdout);

    // Call to the script.
    stat = luainterop_Calculator(_l, 12.96, "*", 3.15, &dret);
    ok = _EvalStatus(stat, __LINE__, "calculator()");
    UT_TRUE(ok);
    UT_STR_EQUAL(_last_error, "No error");
    UT_CLOSE(dret, 40.824, 0.001);

    stat = luainterop_DayOfWeek(_l, "Moonday", &iret);
    ok = _EvalStatus(stat, __LINE__, "day_of_week()");
    UT_TRUE(ok);
    UT_STR_EQUAL(_last_error, "No error");
    UT_EQUAL(iret, 3);

    stat = luainterop_FirstDay(_l, &sret);
    ok = _EvalStatus(stat, __LINE__, "first_day()");
    UT_TRUE(ok);
    UT_STR_EQUAL(_last_error, "No error");
    UT_STR_EQUAL(sret, "Hamday");

    stat = luainterop_InvalidFunc(_l, &bret);
    ok = _EvalStatus(stat, __LINE__, "invalid_func()");
    UT_FALSE(ok);
    UT_STR_CONTAINS(_last_error, "INTEROP_BAD_FUNC_NAME invalid_func()");

    stat = luainterop_InvalidArgType(_l, "abc", &bret);
    ok = _EvalStatus(stat, __LINE__, "invalid_arg()");
    UT_FALSE(ok);
    UT_STR_CONTAINS(_last_error, "LUA_ERRRUN invalid_arg()");
    UT_STR_CONTAINS(_last_error, "attempt to add a \'string\' with a \'number\'");

    stat = luainterop_InvalidRetType(_l, &iret);
    ok = _EvalStatus(stat, __LINE__, "invalid_ret_type()");
    UT_FALSE(ok);
    UT_STR_CONTAINS(_last_error, "INTEROP_BAD_RET_TYPE invalid_ret_type()");

    // Force error - C calls lua which calls error(). This is fatal.
    stat = luainterop_ErrorFunc(_l, 1, &bret);
    ok = _EvalStatus(stat, __LINE__, "error_func(1)");
    UT_FALSE(ok);
    UT_STR_CONTAINS(_last_error, "user_lua_func3() raises error()");

    // Force error - C calls lua which calls C which calls luaL_error().
    stat = luainterop_ErrorFunc(_l, 2, &bret);
    ok = _EvalStatus(stat, __LINE__, "error_func(2)");
    UT_FALSE(ok);
    UT_STR_CONTAINS(_last_error, "Let's blow someing up in lua");

    UT_INFO("Fini!", "");
    lua_close(_l);

    if (_log_out != stdout)
    {
        fclose(_log_out);
    }
    if (_error_out != stdout)
    {
        fclose(_error_out);
    }

    return 0;
}    



//---------------- Call host functions from Lua - work functions -------------//

//--------------------------------------------------------//
int luainteropwork_GetTimestamp()
{
    _timestamp += 100;
    return _timestamp;
}

//--------------------------------------------------------//
bool luainteropwork_Log(int level, const char* msg)
{
    snprintf(_last_log, sizeof(_last_log), "Log LVL%d %s", level, msg);
    return true;
}

//--------------------------------------------------------//
const char* luainteropwork_GetEnvironment(double temp)
{
    static char buff[50];
    snprintf(buff, sizeof(buff), "Temperature is %.1f degrees", temp);
    return buff;
}

//--------------------------------------------------------//
bool luainteropwork_ForceError()
{
    luaL_error(_l, "Let's blow someing up in lua");
    return true;
}


//---------------- Test helpers -------------//


//--------------------------------------------------------//
bool _EvalStatus(int stat, int line, const char* format, ...)
{
    // TODO2 useful?
    //     luaL_traceback(L, L, NULL, 1);
    //     snprintf(buff, BUFF_LEN-1, "%s | %s | %s", lua_tostring(L, -1), lua_tostring(L, -2), lua_tostring(L, -3));
    //     fprintf(fout, "   %s\n", buff);

    bool ok = true;
    strcpy(_last_error, "No error");

    if (stat >= LUA_ERRRUN)
    {
        ok = false;

        // Format info string.
        char info[100];
        va_list args;
        va_start(args, format);
        vsnprintf(info, sizeof(info) - 1, format, args);
        va_end(args);

        // Readable error string.
        const char* sstat = NULL;
        switch (stat)
        {
            // generic LUA_OK
            case 0:                         sstat = "NO_ERR"; break;
            // lua
            case LUA_YIELD:                 sstat = "LUA_YIELD"; break; // the thread(coroutine) yields.
            case LUA_ERRRUN:                sstat = "LUA_ERRRUN"; break; // a runtime error.
            case LUA_ERRSYNTAX:             sstat = "LUA_ERRSYNTAX"; break; // syntax error during pre-compilation
            case LUA_ERRMEM:                sstat = "LUA_ERRMEM"; break; // memory allocation error. For such errors, Lua does not call the message handler.
            case LUA_ERRERR:                sstat = "LUA_ERRERR"; break; // error while running the error handler function
            case LUA_ERRFILE:               sstat = "LUA_ERRFILE"; break; // a file - related error; e.g., it cannot open or read the file.
            // lbot
            case INTEROP_BAD_FUNC_NAME:     sstat = "INTEROP_BAD_FUNC_NAME"; break; // function not in loaded script
            case INTEROP_BAD_RET_TYPE:      sstat = "INTEROP_BAD_RET_TYPE"; break; // script doesn't recognize function arg type
            // app specific
            // ...
            default:                        sstat = "UNKNOWN_ERROR"; break;
        }

        // Additional error message.
        const char* errmsg = NULL;
        if (stat <= LUA_ERRFILE && lua_gettop(_l) > 0) // internal lua error - get error message on stack if provided.
        {
            errmsg = lua_tostring(_l, -1);
        }
        // else app error

        // Log the error info.
        if (errmsg == NULL)
        {
            snprintf(_last_error, sizeof(_last_error), "%s %s", sstat, info);
        }
        else
        {
            snprintf(_last_error, sizeof(_last_error), "%s %s\n%s", sstat, info, errmsg);
        }
        logger_Log(LVL_INFO, line, _last_error);

        // Also spit it out.
        //fprintf(_error_out, "ERROR %s\n", _last_error);
    }

    return ok;
}
