
echo off

:: Set the lua path.
set LUA_PATH=;;C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

:: Run the unit tests.  Test\test_pnut.lua
pushd ".."
lua pnut_runner.lua  Test\test_stringex.lua  Test\test_utils.lua  Test\test_class.lua

popd
