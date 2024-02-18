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

static bool _EvalStatus(int stat, const char* format, ...);

void FakeApp();

static int _host_cnt = 0;

static bool _app_running = false;

// Point these where you like.
static FILE* _log_out = stdout;
static FILE* _error_out = stdout;


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

    stat = luaL_loadfile(_l, "bad_script_file_name.lua");
    _EvalStatus(stat, "load script file failed"); // probably handle manually
//ERROR LUA_ERRFILE load script file failed
//cannot open bad_script_file_name.lua : No such file or directory

    stat = luaL_loadfile(_l, "C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\test_code\\test_code_ch\\script7.lua");
    _EvalStatus(stat, "load script file failed"); // probably handle manually
//ERROR LUA_ERRSYNTAX load script file failed
//...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:64 : unexpected symbol near ')'

    // Run the script to init everything.
    stat = lua_pcall(_l, 0, LUA_MULTRET, 0);
    _EvalStatus(stat, "execute script failed");
//ERROR LUA_ERRRUN execute script failed
//attempt to call a string value

    //luautils_DumpGlobals(_l, stdout);

    // Work it.  while (_app_running)
    for (int i = 0; i < 10; i++)
    {
        int ires = 0;
        double dres = 0;

        // Call lua functions from host. These call lua_pcall() and luaex_docall() which calls lua_pcall()

        stat = luainterop_MyLuaFunc(_l, "booga booga", i, 909, &ires);
        printf(">>>%d\n", ires);
        _EvalStatus(stat, "my_lua_func()");
//ERROR INTEROP_BAD_FUNC_NAME my_lua_func

//lua script calls error() yields
//ERROR LUA_ERRRUN my_lua_func
//...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:59 : user_lua_func3() raises error()
//stack traceback :
//[C] : in function 'error'
//...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:59 : in function 'user_lua_func3'        (...tail calls...)
//...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:32 : in function 'my_lua_func'

        stat = luainterop_MyLuaFunc2(_l, true, &dres);
        _EvalStatus(stat, "my_lua_func2()");

        stat = luainterop_NoArgsFunc(_l, &dres);
        _EvalStatus(stat, "no_args_func()");
    }

    // Fini!
    lua_close(_l);
}


//---------------- Call host functions from Lua - work functions -------------//

bool luainteropwork_MyLuaFunc3(double arg_one)
{
    return arg_one > 100.0;
}

double luainteropwork_FuncWithNoArgs()
{
    return 123.4;
}


//--------------------------------------------------------//
bool _EvalStatus(int stat, const char* format, ...)
{
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

        fprintf(_error_out, "ERROR %s %s\n", sstat, info);
        if (errmsg != NULL)
        {
            fprintf(_error_out, "%s\n", errmsg);
        }
    }

    return has_error;
}


//static int Good(int i)
//{
//    printf("Good(%d)", i);
//    return 0;
//}
//
//static int Bad(int i)
//{
//    //luaL_error(_l, "Bad(%d)", i);
//    return 0;
//}
//
//static int FuncSub3()
//{
//    return ++_host_cnt;
//}
//
//static int FuncSub2()
//{
//    return FuncSub3();
//}
//
//static int FuncSub()
//{
//    return FuncSub2();
//}

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
