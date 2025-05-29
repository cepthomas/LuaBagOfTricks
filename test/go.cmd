
echo off
cls

:: Unit tests: test_stringex test_utils test_types test_class test_pnut test_list test_tableex
set LUA_PATH=?.lua;..\?.lua;;
rem lua ..\pnut_runner.lua  test_stringex test_utils test_types test_class test_pnut test_list test_tableex
lua ..\pnut_runner.lua test_pnut


:: or like this: test\* test_stringex test_utils test_types test_class test_pnut test_list test_tableex
rem pushd ..
rem set LUA_PATH=?.lua;..\?.lua;;
rem lua pnut_runner.lua  test\test_stringex
rem popd



:: Debugex tests.
rem set LUA_PATH=?.lua;..\?.lua;%APPDATA%\luarocks\share\lua\5.4\?.lua;;
rem set LUA_CPATH=%APPDATA%\luarocks\lib\lua\5.4\?.dll;;
rem lua test_debugex.lua

