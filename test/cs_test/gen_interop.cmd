cls
echo off

:: Convert spec into interop library.

:: Build the interop. Note: need explicit paths - lua doesn't know file system.
pushd "..\.."
lua gen_interop.lua -cs -d -t test\cs_test\interop_spec_cs.lua test\cs_test
popd
