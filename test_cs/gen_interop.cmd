cls
echo off

:: Convert spec into interop library.

:: Build the interop. Note: need explicit paths - lua doesn't know file system.
pushd ".."
lua gen_interop.lua -cs -d test_cs\interop_spec_cs.lua test_cs
popd
