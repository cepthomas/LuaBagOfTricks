cls
echo off

:: Convert spec into interop library.

:: Build the interop. Note: need explicit paths - lua doesn't know file system.
pushd "..\.."
lua gen_interop.lua -ch -d -t test\ch_test\interop_spec_ch.lua test\ch_test
popd
