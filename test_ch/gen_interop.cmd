cls
echo off

:: Convert spec into interop library.

:: Build the interop.
pushd ".."
lua gen_interop.lua -ch test_ch\interop_spec_ch.lua test_ch
popd
