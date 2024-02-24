# Lua Bag Of Tricks
- Making lua life easier. For me.
- Pure Lua so far so *should* work anywhere.

## pnut
`pnut.lua` and `pnut_runner.lua` comprise a minimalist unit test framework based on previous implementations in C/C++/C#.
See the Test directory for an example of how to use it.

## utils
Handy collected odds and ends for tables, math, validation, errors, ...

## stringex
String functions. Some pieces-parts lifted from  [Penlight](https://github.com/lunarmodules/Penlight).

## template
Slightly modified version of [template.lua](https://github.com/lunarmodules/Penlight).
Removed dependencies on other penlight components including `LuaFileSystem` so it's standalone now.
Used for generating language specific interop.

## debugger
Slightly modified version of the nifty [debugger.lua](https://github.com/slembcke/debugger.lua).

## interop
Generates C# and C code for the standard lua interop via `gen_interop.lua`.
Two test projects demonstrate how to use it:
- Test\test_cs
- Test\test_ch

## validators
Utilities for validation of lua data types.

## C source_code
Several functions to support the C side of lua applications.

## Talk about test(s)

I'm using 64 bit Lua 5.4.2 from https://luabinaries.sourceforge.net/download.html.
