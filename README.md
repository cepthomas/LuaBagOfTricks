# LuaBagOfTricks
- Making lua life easier (for me).
- Pure Lua so far so *should* work anywhere.
- Uses 64 bit Lua 5.4.2 (\lua54) from https://luabinaries.sourceforge.net/download.html.

## pnut
`pnut.lua` and `pnut_runner.lua` comprise a minimalist unit test framework based on previous implementations in C/C++/C#.
See the Test directory for an example of how to use it.

## lbot_utils
Handy collected odds and ends for tables, math, validation, errors, ...

## stringex
String functions. Some pieces-parts lifted from  [Penlight](https://github.com/lunarmodules/Penlight).

## debugger
Slightly modified version of the nifty [debugger.lua](https://github.com/slembcke/debugger.lua).

## template
Slightly modified version of [template.lua](https://github.com/lunarmodules/Penlight).
Removed dependencies on other penlight components including `LuaFileSystem` so it's standalone now.
Used for generating language specific interop.

## luaex.c/h
Several functions to support the C side of lua applications:
- hardened call mechanism
- misc handy utils
