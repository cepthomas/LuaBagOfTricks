cls
echo off

:: Convert spec into interop library.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

:: Build the interop. Note: need explicit paths - lua doesn't know file system.
pushd "..\.."
lua gen_interop.lua -ch -d -t Test\ch_test\interop_spec_ch.lua Test\ch_test
popd
