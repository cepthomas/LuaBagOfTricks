cls
echo off

:: Convert spec into interop library.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;


:: Build the interop. TODO need explicit paths - lua doesn't know file system.
rem pushd ".."
rem lua gen_interop.lua -cs -d -t "Test\interop_spec.lua" "C:\Dev\repos\Lua\LuaBagOfTricks\Test\cs_test"
rem popd
lua gen_interop.lua -cs -d -t interop_spec_cs.lua .
