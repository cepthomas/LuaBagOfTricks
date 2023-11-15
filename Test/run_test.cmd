cls
echo off

:: Script to run LuaBagOfTricks unit tests.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

:: Run the unit tests. test_pnut test_utils
pushd ".."
lua pnut_runner.lua Test\test_utils
popd
