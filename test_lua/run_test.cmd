
echo off

:: Set the lua path.
set LUA_PATH=;;C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

pushd ".."

:: Run the unit tests.
rem  test_stringex.lua  test_utils.lua  test_class.lua  test_pnut.lua
lua pnut_runner.lua  test_lua\test_pnut.lua

popd
