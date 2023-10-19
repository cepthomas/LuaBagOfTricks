# LuaBagOfTricks

- Applying the KISS principle.
- Making lua life easier. For me.
- Uses Lua 5.4 on Windows. It's pure Lua so far so *should* work anywhere.

## pnut
`pnut\pnut_runner.lua` comprise a minimalist unit test framework based on implementations in other languages (C/C++/C#).
See the Test directory as example of how to use it.

## utils.lua
Handy collected odds and ends.



## interop

See `interop_spec.lua` for example.

Supported arg and return value types: B=boolean I=integer N=number S=string T=tableex


https://github.com/slembcke/debugger.lua

Uses a slightly hacked version of template.lua from https://github.com/lunarmodules/Penlight.
- Doesn't support nested expansions like:
`l.$(to_funcs[$(func.ret.type)])`



TODO2 support enums?

TODO2 clean up C:\Dev\repos\Lua\stuff\notes.txt and lua cheatsheet --> lua-notes.ntr


