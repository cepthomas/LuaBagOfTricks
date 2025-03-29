# LuaBagOfTricks

Making Lua life easier (for me).

It's really only meant for Windows but could be coerced to other platforms.
The `*.lua` are pure Lua modules so *should* work anywhere.

This is intended to be used in client projects by one of several means:
  - git submodule
  - symlink: `mklink /d some_path\Nebulua\LBOT other_path\LuaBagOfTricks`
  - copy of pertinent parts

Tests and examples are found in a separate repo [LbotImpl](https://github.com/cepthomas/LbotImpl.git).

- `pnut.lua` and `pnut_runner.lua` comprise a minimalist unit test framework.
- `lbot_utils.lua`: Handy collected odds and ends for tables, math, validation, errors, ...
- `stringex.lua`: Various string functions. Some pieces-parts lifted from  [Penlight](https://github.com/lunarmodules/Penlight).
- `debugger.lua`: Slightly modified version of the nifty [debugger.lua](https://github.com/slembcke/debugger.lua).
- `template.lua`: lightly modified version of [template.lua](https://github.com/lunarmodules/Penlight).
  Removed dependencies on other penlight components including `LuaFileSystem` so it's standalone now.
  Generally useful and used here primarily for generating language specific interop.
- `lua54` folder contains Lua reference for integration in other Lua projects.
  64 bit Lua 5.4.2 from https://luabinaries.sourceforge.net/download.html.
- `*interop*.lua`: Tools to generate interop glue code for embedding Lua in various hosts - C/C#/.NET.
  See [Lua Interop](doc/Interop.md)
