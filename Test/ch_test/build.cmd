
echo off
cls

:: Setup dirs and files.
mkdir build
cd build
rem del /F /Q *.*

:: Build the app.
cmake -G "MinGW Makefiles" ..
make
cd ..
