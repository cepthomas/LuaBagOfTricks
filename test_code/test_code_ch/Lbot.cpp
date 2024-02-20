#include <cstdio>
#include <cstring>
#include <fstream>
#include "pnut.h"

int main()
{
    // Run the requested tests.
    TestManager& tm = TestManager::Instance();
    std::vector<std::string> whichSuites;
    whichSuites.emplace_back("INTEROP");
    whichSuites.emplace_back("UTILS");
    std::ofstream s_ut("_test.txt", std::ofstream::out);
    tm.RunSuites(whichSuites, 'r', &s_ut);
    s_ut.close();

    return 0;
}

/*
TODO2 put this somewhere:

====================== errors/print/... ====================

custom stream for error output? use stderr? https://www.gnu.org/software/libc/manual/html_node/Custom-Streams.html

===== log
- traditional to FILE* (fp or stdout or)

lua-C:
int logger_Init(FILE* fp); // File stream to write to. Can be stdout.
int logger_Log(log_level_t level, int line, const char* format, ...);

lua-L:
host_api.log(level, msg) => calls the lua-C functions. there is no standalone lua-L logger.
> The I/O library provides two different styles for file manipulation. The first one uses implicit file handles; that is, there are operations to set a default input file and a default output file, and all input/output operations are done over these default files. The second style uses explicit file handles.
> When using implicit file handles, all operations are supplied by table io. When using explicit file handles, the operation io.open returns a file handle and then all operations are supplied as methods of the file handle.
> The table io also provides three predefined file handles with their usual meanings from C: io.stdin, io.stdout, and io.stderr. The I/O library never closes these files.
> Unless otherwise stated, all I/O functions return fail on failure, plus an error message as a second result and a system-dependent error code as a third result, and some non-false value on success.


===== print/printf
- also dump/Dump - like print/printf but larger size
- ok in standalone scripts like gen_interop.lua  pnut_runner.lua  etc
- ok in C main functions
- ok in test code
- quicky debug - don't leave them in
> use fp or stdout only
> lua-L print => io.write() -- default is stdout, change with io.output()
> lua-C printf => fprintf(FILE*) -- default is stdout, change with lautils_SetOutput(FILE* fout); user supplies FILE* fout


===== error
- means fatal here.
-   => originate in lua-L code (like user/script syntax errors) or in lua-C code for similar situations.
- lua-L:
    - Only the app (top level - user visible) calls error(message [, level]) to notify the user of e.g. app syntax errors.
    - internal libs should never call error(), let the client deal.
> use stdout or kustom only + maybe log_error()

! lua-L error(message [, level])  Raises an error (see §2.3) with message as the error object. This function never returns.
... these trickle up to the caller via luaex_docall/lua_pcall return

! lua-C host does not call luaL_error(lua_State *L, const char *fmt, ...);
only call luaL_error() in code that is called from the lua side. C side needs to handle host-call-lua() manually via status codes, error msgs, etc.


- => collected/handled by:
- lua-C lua_pcall (lua_State *L, int nargs, int nresults, int msgh);
Calls a function (or a callable object) in protected mode.
    => only exec.c - probably? use luaex_docall()
! lua-C app luaex_docall(lua_State* l, int narg, int nres)
    => calls lua_pcall()
    => has _handler which calls luaL_traceback(l, l, msg, 1);

? lua-L pcall (f [, arg1, ···]) Calls the function f with the given arguments in protected mode.
    => only used for test, debugger, standalone scripts
    => not currently used: xpcall (f, msgh [, arg1, ···])  sets a new message handler msgh.

*/