rem Script to demonstrate how to run lbot unit tests.

cls
echo off

rem Set the lua path to the lbot dir and where your test script lives. Note the double semi-colon includes the standard lua path.
set LUA_PATH=%LUA_PATH%;C:\Dev\repos\LuaBagOfTricks\?.lua;C:\Dev\repos\LuaBagOfTricks\Test\?.lua;;

rem Run the tests. test_pnut
lua C:\Dev\repos\LuaBagOfTricks\pnut_runner.lua test_utils test_pnut
rem or like this ->
rem cd C:\Dev\repos\LuaBagOfTricks
rem lua pnut_runner.lua test_pnut
