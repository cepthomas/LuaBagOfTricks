
echo off

:: Setup dirs and files.
if not exist build_test mkdir build_test

pushd build_test

:: Build the app.
cmake -G "MinGW Makefiles" ..
make

popd
