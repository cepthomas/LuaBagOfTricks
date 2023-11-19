cls
echo off

:: Script to run LuaBagOfTricks unit tests.

:: Set the lua path.
set LUA_PATH=;;C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

:: Run the unit tests.
pushd ".."
lua pnut_runner.lua Test\test_utils.lua Test\test_class.lua Test\test_pnut.lua
popd
