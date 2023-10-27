# LuaBagOfTricks

- Applying the KISS principle.
- Making lua life easier. For me.
- Uses Lua 5.4 on Windows. It's pure Lua so far so *should* work anywhere.

## pnut
`pnut\pnut_runner.lua` comprise a minimalist unit test framework based on implementations in other languages (C/C++/C#).
See the Test directory as example of how to use it.

## utils
Handy collected odds and ends.


## errors ???


## interop

See `interop_spec.lua` for example.

Supported arg and return value types: B=boolean I=integer N=number S=string T=TableEx

:: Build the interop. TODO need explicit paths - lua doesn't know file system.

## FOSS components

- Uses a slightly hacked version of [template.lua](https://github.com/lunarmodules/Penlight). Removed dependencies on other penlight components including LuaFileSystem. It's standalone now.
- Modified version of the nifty [debugger.lua](https://github.com/slembcke/debugger.lua).

