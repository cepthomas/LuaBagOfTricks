
echo off
cls

rem Unit tests: test\* test_stringex test_utils test_types test_class test_pnut test_list test_tableex
rem pushd ..
rem LUA_PATH=?.lua;..\?.lua;;
rem lua pnut_runner.lua  test\test_stringex
rem popd


rem :: Unit tests: test_stringex test_utils test_types test_class test_pnut test_list test_tableex
rem set LUA_PATH=?.lua;..\?.lua;;
rem lua ..\pnut_runner.lua  test_stringex


:: Debugex tests.
set LUA_PATH=?.lua;..\?.lua;%APPDATA%\luarocks\share\lua\5.4\?.lua;;
set LUA_CPATH=%APPDATA%\luarocks\lib\lua\5.4\?.dll;;
lua test_debugex.lua

