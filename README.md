# LuaBagOfTricks

Making Lua life easier (for me).

It's really only meant for Windows but could be coerced to other platforms.
The `*.lua` are pure Lua modules so *should* work anywhere.

This is intended to be used in client projects by one of several means:
  - git submodule
  - symlink: `mklink /d host_app\LBOT install_path\LuaBagOfTricks`
  - or just copy parts of interest

Tests and examples are found in a separate repo [LbotImpl](https://github.com/cepthomas/LbotImpl.git).

Some parts are borrowed and/or modified from  [Penlight](https://github.com/lunarmodules/Penlight)

Code mostly follows [luarocks style guide](https://github.com/luarocks/lua-style-guide)

- `pnut.lua` and `pnut_runner.lua` comprise a minimalist unit test framework.
- `lbot_utils.lua`, `lbot_types.lua`: Handy collected odds and ends for tables, math, validation, errors, ...
- `stringex.lua`: Various string functions. .
- `debugger.lua`: Slightly modified version of [debugger.lua](https://github.com/slembcke/debugger.lua).
- `template.lua`: lightly modified version of [template.lua](https://github.com/lunarmodules/Penlight).
- `*interop*.lua`: Tools to generate interop glue code for embedding Lua in various hosts - C/C#/.NET.
  See [Lua Interop](Interop.md)
- `class.lua` - General purpose Lua class.
- `List.lua` - General purpose true homogenous list.
- `Tableex.lua`: Various table functions.
- `lua54` folder contains Lua reference for integration in other Lua projects. 64 bit Lua 5.4.2 from https://luabinaries.sourceforge.net/download.html.
