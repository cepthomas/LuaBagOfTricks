cls
echo off

rem Script to run lbot unit tests.

rem Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

rem Enable debugger terminal color support.
set TERM=ansi
rem https://gist.githubusercontent.com/mlocati/fdabcaeb8071d5c75a2d51712db24011/raw/b710612d6320df7e146508094e84b92b34c77d48/win10colors.cmd
rem echo [101;93m STYLES [0m
rem echo ^<ESC^>[0m [0mReset[0m
rem echo ^<ESC^>[1m [1mBold[0m
rem echo ^<ESC^>[4m [4mUnderline[0m
rem echo ^<ESC^>[7m [7mInverse[0m

goto interop

rem Run the tests. test_pnut test_utils test_interop
lua ..\pnut_runner.lua test_interop
rem TODO1 or like this ->
rem pushd ".."
rem lua pnut_runner.lua Test\test_pnut
rem popd
rem ???
rem lua ..\gen_interop.lua -cs %cd%\interop_spec.lua %cd%\out\GeneratedInterop.cs
goto end

:interop
rem lua ..\gen_interop.lua -cs C:\Dev\repos\Lua\LuaBagOfTricks\Test\interop_spec.lua C:\Dev\repos\Lua\LuaBagOfTricks\out\GeneratedInterop.cs
rem TODO1 need absolute path above.

rem This does work.
pushd ".."
lua gen_interop.lua -cs Test\interop_spec.lua Test\out\GeneratedInterop.cs
popd

:end
