cls
echo off

:: Convert spec into interop library.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;


:: Build the interop. TODO need explicit paths - lua doesn't know file system.
pushd ".."
rem lua gen_interop.lua -cs -d -t "Test\interop_spec.lua" "C:\Dev\repos\Lua\LuaBagOfTricks\Test\cs_test"
lua gen_interop.lua -ch -d -t "Test\interop_spec.lua" "C:\Dev\repos\Lua\LuaBagOfTricks\Test\c_test"
popd

:end
