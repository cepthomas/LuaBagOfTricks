
echo off

:: Set the lua path.
set LUA_PATH=;;C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

pushd ".."

:: Run the unit tests.TODO1
rem lua pnut_runner.lua  Test\test_stringex.lua  Test\test_utils.lua  Test\test_class.lua
lua pnut_runner.lua  Test\test_stringex.lua
rem lua pnut_runner.lua  Test\test_pnut.lua

popd