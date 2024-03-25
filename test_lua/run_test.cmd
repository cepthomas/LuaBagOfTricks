
echo off

:: Set the lua path. TODO1 test
set LUA_PATH=;;%~dp0\..\?.lua;%~dp0\?.lua;

pushd ".."

:: Run the unit tests.
rem  test_stringex.lua  test_utils.lua  test_class.lua  test_pnut.lua
lua pnut_runner.lua  test_lua\test_pnut.lua

popd
