cls
echo off

rem Script to run lbot unit tests.

rem Set the lua path to:
rem   - the lbot dir
rem   - where your test script lives
rem   - where your packages live
rem   . Note the double semicolon includes the standard lua path.
set LUA_PATH=;;C:\Dev\repos\LuaBagOfTricks\?.lua;C:\Dev\repos\LuaBagOfTricks\Test\?.lua;C:\Dev\repos\Lua\LuaBagOfTricks\lua\debugger\?.lua;C:\Dev\repos\Lua\LuaBagOfTricks\lua\pl\?.lua;


rem Run the tests. test_pnut test_utils test_interop
lua C:\Dev\repos\LuaBagOfTricks\pnut_runner.lua test_interop
rem or like this ->
rem cd C:\Dev\repos\LuaBagOfTricks
rem lua pnut_runner.lua test_pnut
