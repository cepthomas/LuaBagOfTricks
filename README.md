# LuaBagOfTricks

A plethora of Lua odds and ends accumulated over the years.

- Some parts are ported from [Penlight](https://github.com/lunarmodules/Penlight), mainly to remove module/function
  dependencies so they are standalone.

- Built on Windows using Lua 5.4 but could be coerced to other platforms. The `*.lua` modules are
  pure Lua (except debugex.lua) so *should* work anywhere.

- This is intended to be used in client projects by one of several means:
  - git submodule
  - symlink: `mklink /d your_app\LBOT your_git_clone\LuaBagOfTricks`
  - or just copy parts of interest

- Code mostly follows [luarocks style guide](https://github.com/luarocks/lua-style-guide).

- `lua54` folder contains Lua reference for integration in other Lua projects. 64 bit Lua 5.4.2 from https://luabinaries.sourceforge.net/download.html.

# Libraries

- `lbot_utils.lua` - odds and ends for tables, math, etc.
- `lbot_types.lua` - various arg type and value checkers.
- `stringex.lua` - various extended string functions.
- `tableex.lua` - table helper functions.
- `Class.lua` - general purpose Lua class.
- `List.lua` - general purpose true homogenous list.
- `Dictionary.lua` - general purpose homogenous map container.
- `template.lua` - slightly modified version of [template.lua](https://github.com/lunarmodules/Penlight).

In general, all failures at this level are considered fatal and call `error()`.

# PNUT

`pnut.lua` and `pnut_runner.lua` comprise a minimalist unit test framework. See `test\\test_pnut.lua` for examples.

# Debugger

`debugger.lua` is a slightly modified version of [debugger.lua](https://github.com/slembcke/debugger.lua).

`debugex.lua` is an extensively modified version of `debugger.lua`. It adds:
- Support for breaking on `error()`.
- Remote client via socket - useful for debugging embedded scripts. This needs `require('socket')`.
  Note that if you are using Visual Studio, you can coerce WinForms to provide a console for
  debugging - see https://github.com/cepthomas/LuaInterop/tree/main/CppCli.
