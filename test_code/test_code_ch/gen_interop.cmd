cls
echo off

:: Convert spec into interop library.

:: Build the interop. Note: need explicit paths - lua doesn't know file system.
pushd "..\.."
lua gen_interop.lua -ch -d -t test_code\test_code_ch\interop_spec_ch.lua test_code\test_code_ch
popd
