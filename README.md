# LuaBagOfTricks

- Making lua life easier. For me.
- Uses Lua 5.4 on Windows. It's pure Lua so far so *should* work anywhere.

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
Generates C# and C code for the standard lua interop. The Test projects demonstrate how to use it:
- Test\cs_test\interop_spec_cs.lua
- Test\CH_test\interop_spec_CH.lua

## source dir

Several functions to support the C side of lua applications. Currently intended to be simple cut-and-paste.
