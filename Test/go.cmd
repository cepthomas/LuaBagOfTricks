cls
echo off

rem Script to run lbot unit tests.

rem Set the lua path.
set LUA_PATH=;;C:\Dev\repos\Lua\LuaBagOfTricks\?.lua; ^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

rem Enable debugger terminal color support.
set TERM=ansi

rem Run the tests. test_pnut test_utils test_interop
lua ..\pnut_runner.lua test_interop
rem TODO1 or like this ->
rem cd C:\Dev\repos\LuaBagOfTricks
rem lua pnut_runner.lua test_pnut

rem lua ..\gen_interop.lua -cs %cd%\interop_spec.lua %cd%\out\GeneratedInterop.cs
