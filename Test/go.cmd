cls
echo off

:: Script to run lbot unit tests.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

:: Enable debugger terminal color support.
rem set TERM=ansi

goto interop

:: Run the tests. test_pnut test_utils test_interop
pushd ".."
lua pnut_runner.lua Test\test_pnut
popd
goto end

:interop

pushd ".."
lua gen_interop.lua -cs -d -t Test\interop_spec.lua Test\out\GeneratedInterop.cs
popd
rem TODO paths are messed up - lua doesn't know file system.
rem lua ..\gen_interop.lua -cs interop_spec.lua out\GeneratedInterop.cs

:end
