cls
echo off

:: Convert spec into interop library.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;


:: Build the interop.
pushd "..\.."
lua gen_interop.lua -cs -d -t Test\cs_test\interop_spec_cs.lua Test\cs_test
popd
