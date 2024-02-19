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
static int _host_cnt = 0;
static bool _app_running = false;
static char _buff[100];
static char _last_log[100];

// Point these where you like.
static FILE* _log_out = stdout;
static FILE* _error_out = stdout;

static bool _EvalStatus(int stat, int line, const char* format, ...);

static void FakeApp();


int main()
{
    // Init system before running tests.
    _log_out = fopen("log_out.txt", "w");
    logger_Init(_log_out); // stdout

    FakeApp();

    //or:
    // Run the requested tests.
    //TestManager& tm = TestManager::Instance();
    //std::vector<std::string> whichSuites;
    //whichSuites.emplace_back("LUAUTILS");
    //std::ofstream s_ut("test_out.txt", std::ofstream::out);
    //tm.RunSuites(whichSuites, 'r', &s_ut);
    //s_ut.close();

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

// Roughly how to organize an app.
void FakeApp()
{
    int stat;
    bool ok = false;
    int iret = 0;
    double dret = 0;
    bool bret = false;
    const char* sret = NULL;

    // Init internal stuff.
    _l = luaL_newstate();
     luautils_EvalStack(_l, stdout, 0);

    // Load std libraries.
    luaL_openlibs(_l);

    // Load host funcs into lua space. This table gets pushed on the stack and into globals.
    luainterop_Load(_l);

    // Pop the table off the stack as it interferes with calling the module functions.
    lua_pop(_l, 1);

    // Load the script file. Pushes the compiled chunk as a Lua function on top of the stack
    // - or pushes an error message.
    const char* fn = "";

    // Try to load non-existent file.
    fn = "bad_script_file_name.lua";
    stat = luaL_loadfile(_l, fn);
    ok = _EvalStatus(stat, __LINE__, "load script file failed");
    //ERROR LUA_ERRFILE load script file failed
    //cannot open bad_script_file_name.lua : No such file or directory

    fn = "C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\test_code\\test_code_ch\\script6.lua";
    stat = luaL_loadfile(_l, fn);
    ok = _EvalStatus(stat, __LINE__, "load script file failed");
    //ERROR LUA_ERRSYNTAX 92 load script file failed
    //    ...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script6.lua:7 : syntax error near 'ts'

    fn = "C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\test_code\\test_code_ch\\script7.lua";
    stat = luaL_loadfile(_l, fn);
    ok = _EvalStatus(stat, __LINE__, "load script file failed");
    // Should be ok.

    // If stat is ok, run the script to init everything.
    stat = lua_pcall(_l, 0, LUA_MULTRET, 0);
    ok = _EvalStatus(stat, __LINE__, "execute script failed: %s", fn);
    // Should be ok.
    // or:
    //ERROR LUA_ERRRUN execute script failed
    //attempt to call a string value

    // This should be set by the script execution.
    printf(">>>%s\n", _last_log);

    //luautils_DumpGlobals(_l, stdout);

    // Call to the script.
    stat = luainterop_Calculator(_l, 12.96, "*", 3.15, &dret);
    ok = _EvalStatus(stat, __LINE__, "calculator()");

    stat = luainterop_DayOfWeek(_l, "Moonday", &iret);
    ok = _EvalStatus(stat, __LINE__, "day_of_week()");

    stat = luainterop_FirstDay(_l, &sret);
    ok = _EvalStatus(stat, __LINE__, "first_day()");

    stat = luainterop_InvalidFunc(_l, &bret);
    ok = _EvalStatus(stat, __LINE__, "invalid_func()");
    //ERROR INTEROP_BAD_FUNC_NAME 128 invalid function

    stat = luainterop_InvalidArgType(_l, "abc", &bret);
    ok = _EvalStatus(stat, __LINE__, "invalid_arg()");
    //ERROR LUA_ERRRUN 131 invalid arg
    //    ...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:68 : attempt to add a 'string' with a 'number'
    //    stack traceback :
    //[C] : in metamethod 'add'
    //    ...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:68 : in function 'invalid_arg_type'

    stat = luainterop_InvalidRetType(_l, &iret);
    ok = _EvalStatus(stat, __LINE__, "invalid_ret_type()");
    //ERROR INTEROP_BAD_RET_TYPE 140 invalid ret type

    // Force error. This is fatal.
    stat = luainterop_ErrorFunc(_l, &bret);
    ok = _EvalStatus(stat, __LINE__, "error_func()");
    //ERROR LUA_ERRRUN 144 force error
    //    ...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:121 : user_lua_func3() raises error()
    //    stack traceback :
    //[C] : in function 'error'
    //    ...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:121 : in function 'user_lua_func3'
    //    (...tail calls...)

    // Fini!
    lua_close(_l);
}


//---------------- Call host functions from Lua - work functions -------------//

int luainteropwork_GetTimestamp()
{
    _timestamp += 100;
    return _timestamp;
}

bool luainteropwork_Log(int level, const char* msg)
{
    snprintf(_last_log, sizeof(_last_log), "Log LVL%d %s", level, msg);
    return true;
}

const char* luainteropwork_GetEnvironment(double temp)
{
    snprintf(_buff, sizeof(_buff), "Temperature is %.1f degrees", temp);
    return _buff;
}


//--------------------------------------------------------//
bool _EvalStatus(int stat, int line, const char* format, ...)
{
    // TODO1 useful?
    //     luaL_traceback(L, L, NULL, 1);
    //     snprintf(buff, BUFF_LEN-1, "%s | %s | %s", lua_tostring(L, -1), lua_tostring(L, -2), lua_tostring(L, -3));
    //     fprintf(fout, "   %s\n", buff);

    bool has_error = false;

    if (stat >= LUA_ERRRUN)
    {
        has_error = true;

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
        // else cbot or nebulua error

        //char buff2[100];
        //snprintf(buff2, sizeof(buff2) - 1, "Status:%s info:%s", sstat, info);

        fprintf(_error_out, "ERROR %s %d %s\n", sstat, line, info);
        if (errmsg != NULL)
        {
            fprintf(_error_out, "%s\n", errmsg);
        }
    }

    return has_error;
}


/////////////////////////////////////////////////////////////////////////////
UT_SUITE(ERROR_MAIN, "Test error stuff.")
{
    // double dper = nebcommon_InternalPeriod(178);
    // UT_EQUAL(dper, 1.1111);

    // int iper = nebcommon_RoundedInternalPeriod(92);
    // UT_EQUAL(iper, 1234);

    // double msec = nebcommon_InternalToMsec(111, 1033);
    // UT_EQUAL(msec, 1.1111);

    return 0;
}
