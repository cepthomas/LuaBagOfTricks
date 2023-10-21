cls
echo off

:: Script to run lbot unit tests.

:: Set the lua path.
set LUA_PATH=;;^
C:\Dev\repos\Lua\LuaBagOfTricks\?.lua;^
C:\Dev\repos\Lua\LuaBagOfTricks\Test\?.lua;

:: Enable debugger terminal color support.
set TERM=ansi
:: https://gist.githubusercontent.com/mlocati/fdabcaeb8071d5c75a2d51712db24011/raw/b710612d6320df7e146508094e84b92b34c77d48/win10colors.cmd
:: echo [101;93m STYLES [0m
:: echo ^<ESC^>[0m [0mReset[0m
:: echo ^<ESC^>[1m [1mBold[0m
:: echo ^<ESC^>[4m [4mUnderline[0m
:: echo ^<ESC^>[7m [7mInverse[0m

goto interop

:: Run the tests. test_pnut test_utils test_interop
pushd ".."
lua pnut_runner.lua Test\test_pnut
popd
goto end

:interop
rem lua ..\gen_interop.lua -cs C:\Dev\repos\Lua\LuaBagOfTricks\Test\interop_spec.lua C:\Dev\repos\Lua\LuaBagOfTricks\out\GeneratedInterop.cs
rem TODO1 need absolute path above.
:: short_src:..\gen_interop.lua(string)
:: what:main(string)
:: linedefined:0(number)
:: lastlinedefined:0(number)
:: source:@..\gen_interop.lua(string)
:: TODO1 get real path:
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


rem This does work.
pushd ".."
lua gen_interop.lua -cs Test\interop_spec.lua Test\out\GeneratedInterop.cs
popd

:end
