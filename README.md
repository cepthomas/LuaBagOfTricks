# LuaBagOfTricks

Making Lua life easier (for me).

- It's really only meant for Windows but could be coerced to other platforms.
The `*.lua` are pure Lua modules so *should* work anywhere.

- This is intended to be used in client projects by one of several means:
  - git submodule
  - symlink: `mklink /d host_app\LBOT install_path\LuaBagOfTricks`
  - or just copy parts of interest

- Parts are modified from  [Penlight](https://github.com/lunarmodules/Penlight)

- Code mostly follows [luarocks style guide](https://github.com/luarocks/lua-style-guide)

- `lua54` folder contains Lua reference for integration in other Lua projects. 64 bit Lua 5.4.2 from https://luabinaries.sourceforge.net/download.html.

## Libraries

- `lbot_utils.lua` has odds and ends for tables, math, etc.
- `lbot_types.lua` has various arg type and value checkers.
- `stringex.lua`: Various extended string functions.
- `tableex.lua`: Table extended helper functions.
- `Class.lua` - General purpose Lua class.
- `List.lua` - General purpose true homogenous list.
- `Dictionary.lua` - General purpose homogenous map container.

In general, failures at this level are considered fatal and call `error()`.

## Tools
- `pnut.lua` and `pnut_runner.lua` comprise a minimalist unit test framework. See `test` dir for examples.
- `debugger.lua`: Slightly modified version of [debugger.lua](https://github.com/slembcke/debugger.lua).
- `debugex.lua`: Extensively modified version of `debugger.lua`. TODOD details
- `template.lua`: Slightly modified version of [template.lua](https://github.com/lunarmodules/Penlight). Mainly used for interop generation.
