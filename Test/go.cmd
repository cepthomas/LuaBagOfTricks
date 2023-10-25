cls
echo off

:: Script to run lbot unit tests.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

goto interop

:: Run the unit tests. test_pnut test_utils test_interop
pushd ".."
lua pnut_runner.lua "Test\test_interop"
popd

goto end

:interop
:: Build the interop. TODO need explicit paths - lua doesn't know file system.
pushd ".."
lua gen_interop.lua -cs -d -t "Test\interop_spec.lua" "C:\Dev\repos\Lua\LuaBagOfTricks\Test\cs_test"
popd

:end
