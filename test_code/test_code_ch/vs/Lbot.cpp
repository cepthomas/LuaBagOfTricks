#include <cstdio>
#include <cstring>
#include <fstream>
#include "pnut.h"

extern "C"
{
#include <windows.h>
// #include <stdlib.h>
// #include <stdio.h>
// #include <stdarg.h>
// #include <stdbool.h>
// #include <stdint.h>
// #include <string.h>
// #include <float.h>
// #include <time.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "luautils.h"
#include "luainterop.h"

//#include "logger.h"
}

// The main Lua thread.
static lua_State* _l;

// Logs and calls luaL_error() which doesn't return.
static void _EvalStatus(int stat, const char* format, ...);

void FakeApp();

static int _host_cnt = 0;

static bool _app_running = false;


// TODOT lua-C printf => fprintf(FILE*) -- default is stdout, change with lautils_SetOutput(FILE* fout); user supplies FILE* fout

// TODOT luaL_error(lua_State *L, const char *fmt, ...);  Raises an error. The error message format is given by fmt plus any
// extra arguments, following the same rules of lua_pushfstring. It also adds at the beginning of the message the file name
// and the line number where the error occurred, if this information is available. This function never returns, but it is
// an idiom to use it in C functions as return luaL_error(args).
// => in luainterop luainteropwork  interop_ch.lua  exec.c(_EvalStatus)


// Error needs its own stream(s), log and/or print/dump context, needs caller info by level

// - => collected/handled by:
// - lua-C lua_pcall (lua_State *L, int nargs, int nresults, int msgh);
// Calls a function (or a callable object) in protected mode.
//     => only exec.c - probably? use luaex_docall()
// ! lua-C app luaex_docall(lua_State* l, int narg, int nres)
//     => calls lua_pcall()
//     => has _handler which calls luaL_traceback(l, l, msg, 1);

int main()
{
    // To automatically close the console when debugging stops,
    // enable Tools->Options->Debugging->Automatically close the console when debugging stops.

    FakeApp();

    /*
    TestManager& tm = TestManager::Instance();

    // Run the requested tests.
    std::vector<std::string> whichSuites;

    whichSuites.emplace_back("LUAUTILS");

    //// Init system before running tests.
    //FILE* fp_log = fopen("log_out.txt", "w");
    //logger_Init(fp_log); // stdout

    std::ofstream s_ut("test_out.txt", std::ofstream::out);
    tm.RunSuites(whichSuites, 'r', &s_ut);

    //fclose(fp_log);
    s_ut.close();
    */

    return 0;
}


void FakeApp()
{
    int stat;

    ///// Init internal stuff. /////
    _l = luaL_newstate();
    // luautils_EvalStack(_l, 0);

    // Load std libraries.
    luaL_openlibs(_l);

    // Load host funcs into lua space. This table gets pushed on the stack and into globals.
    luainterop_Load(_l);

    // Pop the table off the stack as it interferes with calling the module functions.
    lua_pop(_l, 1);


    stat = 90;// +i;
     _EvalStatus(stat, "arbitrary failure status: %d", stat);


    // Load the script file. Pushes the compiled chunk as a Lua function on top of the stack
    // - or pushes an error message.
    stat = luaL_loadfile(_l, "C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\test_code\\test_code_ch\\vs\\script7.lua");
    _EvalStatus(stat, "load script file failed"); // probably handle manually

    // Run the script to init everything.
    stat = lua_pcall(_l, 0, LUA_MULTRET, 0);
    _EvalStatus(stat, "execute script failed");

    // Work it.  while (_app_running)
    for (int i = 0; i < 10; i++)
    {
        int res;
        double d;

        // Call lua functions from host. These call lua_pcall() and luaex_docall() which calls lua_pcall()

        stat = luainterop_MyLuaFunc(_l, "booga booga", i, 909, &res);
        _EvalStatus(stat, "aaaaa");

        stat = luainterop_MyLuaFunc2(_l, true, &d);
        _EvalStatus(stat, "bbbbb");

        stat = luainterop_NoArgsFunc(_l, &d);
        _EvalStatus(stat, "ccccc");
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
void _EvalStatus(int stat, const char* format, ...)
{
    static char info[100];
    // bool has_error = false;

    if (stat >= LUA_ERRRUN)
    {
        // has_error = true;
        va_list args;
        va_start(args, format);
        vsnprintf(info, sizeof(info) - 1, format, args);
        va_end(args);


        const char* sstat = NULL;
        char st_buff[32];
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


            // // cbot
            // case CBOT_ERR_INVALID_ARG:      sstat = "CBOT_ERR_INVALID_ARG"; break;
            // case CBOT_ERR_ARG_NULL:         sstat = "CBOT_ERR_ARG_NULL"; break;
            // case CBOT_ERR_NO_DATA:          sstat = "CBOT_ERR_NO_DATA"; break;
            // case CBOT_ERR_INVALID_INDEX:    sstat = "CBOT_ERR_INVALID_INDX"; break;
            // // app
            // case NEB_ERR_INTERNAL:          sstat = "NEB_ERR_INTERNAL"; break;
            // case NEB_ERR_BAD_CLI_ARG:       sstat = "NEB_ERR_BAD_CLI_ARG"; break;
            // case NEB_ERR_BAD_LUA_ARG:       sstat = "NEB_ERR_BAD_LUA_ARG"; break;
            // case NEB_ERR_BAD_MIDI_CFG:      sstat = "NEB_ERR_BAD_MIDI_CFG"; break;
            // case NEB_ERR_SYNTAX:            sstat = "NEB_ERR_SYNTAX"; break;
            // case NEB_ERR_MIDI:              sstat = "NEB_ERR_MIDI"; break;
            // default
            default:                        snprintf(st_buff, sizeof(st_buff) - 1, "ERR_%d", stat); sstat = st_buff; break;
        }

        const char* errmsg = "none";

        if (stat <= LUA_ERRFILE) // internal lua error - get error message on stack if provided.
        {
            if (lua_gettop(_l) > 0)
            {
                 errmsg = lua_tostring(_l, -1);
                // luaL_error(l, "Status:%s info:%s errmsg:%s", sstat, buff, errmsg);
                //luaL_error(l, "Status:%s info:%s errmsg:%s", sstat, buff, lua_tostring(l, -1));
            }
            else
            {
                //luaL_error(l, "Status:%s info:%s", sstat, buff);
            }
        }
        else // cbot or nebulua error
        {
            //luaL_error(l, "Status:%s info:%s", sstat, buff);
        }

        char buff2[100];
        snprintf(buff2, sizeof(buff2) - 1, "Status:%s info:%s", sstat, info);

        printf("ERROR:\n%s\n%s\n", buff2, errmsg);

    }
}


static int Good(int i)
{
    printf("Good(%d)", i);
    return 0;
}

static int Bad(int i)
{
    luaL_error(_l, "Bad(%d)", i);
    return 0;
}

static int FuncSub3()
{
    return ++_host_cnt;
}

static int FuncSub2()
{
    return FuncSub3();
}

static int FuncSub()
{
    return FuncSub2();
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
