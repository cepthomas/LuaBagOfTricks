
echo off
cls

rem Unit tests: test\* test_stringex test_utils test_types test_class test_pnut test_list test_tableex
rem pushd ..
rem LUA_PATH=?.lua;..\?.lua;;
rem lua pnut_runner.lua  test\test_stringex
rem popd


:: Unit tests: test_stringex test_utils test_types test_class test_pnut test_list test_tableex
set LUA_PATH=?.lua;..\?.lua;;
lua ..\pnut_runner.lua  test_stringex


rem :: Debugex tests.
rem set LUA_PATH=?.lua;..\?.lua;%APPDATA%\luarocks\share\lua\5.4\?.lua;;
rem set LUA_CPATH=%APPDATA%\luarocks\lib\lua\5.4\?.dll;;
rem lua test_debugex.lua


rem :: Debugger tests.
rem set TERM=1
rem set LUA_PATH=.\?.lua;;
rem lua test_debugger.lua
