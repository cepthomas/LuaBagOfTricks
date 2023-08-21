
cls
echo off

rem Set the lua path to the lbot dir and where your test script lives. Note the double semi-colon includes the standard lua path.
set LUA_PATH=%LUA_PATH%;C:\Dev\repos\LuaBagOfTricks\?.lua;C:\Dev\repos\LuaBagOfTricks\Test\?.lua;;

rem Run the tests.
lua C:\Dev\repos\LuaBagOfTricks\pnut_runner.lua test_pnut test_utils
rem or ->
rem cd C:\Dev\repos\LuaBagOfTricks
rem lua pnut_runner.lua test_pnut.lua
