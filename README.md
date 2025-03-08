# LuaBagOfTricks

Making Lua life easier (for me).

It's really only meant for Windows but could be coerced to other platforms.

# Lua

Pure Lua modules so *should* work anywhere.

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

## interop*
Tools to generate interop glue code for various application types.
See [Implementation](https://github.com/cepthomas/LbotImpl.git) for usage.
- gen_interop.lua - the driver
- interop_c.lua - C flavor
- interop_cppcli.lua - C++/CLI flavor
- interop_csh.lua - C# flavor (uses KeraLuaEx)

# Internal
Several functions to support the C/C++ side of Lua applications:

## luaex.c/h
- hardened call mechanism
- misc utils

# lua54

Reference for all Lua projects.  64 bit Lua 5.4.2 from https://luabinaries.sourceforge.net/download.html.
