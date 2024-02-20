cls
echo off

:: Convert spec into interop library.

:: Build the interop. Note: need explicit paths - lua doesn't know file system.
pushd "..\.."
lua gen_interop.lua -cs -d test_code\test_code_cs\interop_spec_cs.lua test_code\test_code_cs
popd
