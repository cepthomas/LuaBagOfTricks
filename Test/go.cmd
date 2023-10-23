cls
echo off

:: Script to run lbot unit tests.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

:: Enable debugger terminal color support.
rem set TERM=ansi

goto interop

:: Run the tests. test_pnut test_utils test_interop
pushd ".."
lua pnut_runner.lua Test\test_pnut
popd
goto end

:interop
rem lua ..\gen_interop.lua -cs C:\Dev\repos\Lua\LuaBagOfTricks\Test\interop_spec.lua C:\Dev\repos\Lua\LuaBagOfTricks\out\GeneratedInterop.cs
rem TODO0 need absolute path above.
:: -- print("cd:", ut.execute_capture("echo %cd%"))
:: or?
:: short_src:..\gen_interop.lua(string)
:: what:main(string)
:: linedefined:0(number)
:: lastlinedefined:0(number)
:: source:@..\gen_interop.lua(string)
::   get real path:
:: > local fullpath = debug.getinfo(1,"S").source:sub(2)
:: > fullpath = io.popen("realpath '"..fullpath.."'", 'r'):read('a')
:: > fullpath = fullpath:gsub('[\n\r]*$','')
:: >
:: > local dirname, filename = fullpath:match('^(.*/)([^/]-)$')
:: > dirname = dirname or ''
:: > filename = filename or fullpath
:: or?
:: If you have a file somewhere in package.path that require is able to find, then you can also easily get the path by using package.searchpath.
:: If "foo.bar.baz" is the name under which require will load the file, then
:: package.searchpath( "foo.bar.baz", package.path )
:: --> (e.g.) "/usr/share/lua/5.3/foo/bar/baz.lua"
:: gets you the path.
:: or?
:: lua ..\gen_interop.lua -cs %cd%\interop_spec.lua %cd%\out\GeneratedInterop.cs


pushd ".."
lua gen_interop.lua -cs -d -t Test\interop_spec.lua Test\out\GeneratedInterop.cs
popd
rem lua ..\gen_interop.lua -cs interop_spec.lua out\GeneratedInterop.cs

:end
