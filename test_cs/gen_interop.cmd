cls
echo off

:: Convert spec into interop library.

:: Build the interop.
pushd ".."
lua gen_interop.lua -cs test_cs\interop_spec_cs.lua test_cs
popd
