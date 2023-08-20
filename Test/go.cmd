
cls
echo off

rem print(package.path)
rem C:\Program Files\Lua\lua\?.lua
rem C:\Program Files\Lua\lua\?\init.lua
rem C:\Program Files\Lua\?.lua
rem C:\Program Files\Lua\?\init.lua
rem C:\Program Files\Lua\..\share\lua\5.4\?.lua
rem C:\Program Files\Lua\..\share\lua\5.4\?\init.lua
rem .\?.lua
rem .\?\init.lua

rem set LBOT_PATH="C:\Dev\repos\LuaBagOfTricks"
lua pnut_runner.lua .\test_pnut
