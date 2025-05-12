
echo off
cls

rem :: Unit tests.
rem pushd ..
rem set LUA_PATH=.\?.lua;?.lua;;
rem :: Run the unit tests.
rem :: test\test_stringex  test\test_utils  test\test_types  test\test_class  test\test_pnut  test\test_list  test\test_tableex
rem lua pnut_runner.lua  test\test_stringex
rem popd


:: Debugex tests.
set TERM=1
set LUA_PATH=.\?.lua;?.lua;%APPDATA%\luarocks\share\lua\5.4\?.lua;;
set LUA_CPATH=%APPDATA%\luarocks\lib\lua\5.4\?.dll;;
lua test_debugex.lua
