# LuaBagOfTricks

- Making lua life easier. For me.
- Uses Lua 5.4 on Windows. It's pure Lua so far so *should* work anywhere.

## pnut
`pnut.lua` and `pnut_runner.lua` comprise a minimalist unit test framework based on previous implementations in C/C++/C#.
See the Test directory for an example of how to use it.

## utils
Handy collected odds and ends. Includes some third party bits and pieces.

## interop
Generates C# and C code for the standard lua interop.
- Test projects (Windows) demonstrate how to use it.
- Supported arg and return value types: B=boolean I=integer N=number S=string T=TableEx.
- See `interop_spec.lua` for definition of input.
- The C version needs some more infrastructure to support tables.

## FOSS components

Uses slightly modified versions of:
- [template.lua](https://github.com/lunarmodules/Penlight). Removed dependencies on other penlight components including `LuaFileSystem`. It's standalone now. Used for interop.
- The nifty [debugger.lua](https://github.com/slembcke/debugger.lua).

