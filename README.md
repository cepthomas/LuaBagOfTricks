# LuaBagOfTricks

A plethora of Lua odds and ends accumulated over the years.

- Some parts are ported from [Penlight](https://github.com/lunarmodules/Penlight), mainly to remove module/function
  dependencies so they are standalone.

- Built on Windows using Lua 5.4 but could be coerced to other platforms. The `*.lua` modules are
  pure Lua (except debugex.lua) so *should* work anywhere.

- This is intended to be used in client projects by one of several means:
  - git submodule
  - symlink: `mklink /d <current_folder>\LBOT <lbot_source_folder>\LuaBagOfTricks`
  - or just copy parts of interest

- Code mostly follows [luarocks style guide](https://github.com/luarocks/lua-style-guide).

- `lua54` folder contains Lua reference for integration in other Lua projects. 64 bit Lua 5.4.2 from https://luabinaries.sourceforge.net/download.html.

 - 'csrc\luaex.h/c' is some utilities implemented in C and C++, mainly for internal use.
 
 - 'csrc\cliex.h/cpp' is support for the LuaInterop project. Probably should be in that project but problems...


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

`debugex.lua` is an extensively modified version of [debugger.lua](https://github.com/slembcke/debugger.lua).
The basic UI is the same but adds:
- Support for breaking on `error()` by using `dbg.pcall()`.
- Remote client via socket - useful for debugging embedded scripts. This requires the `socket` module installed.
- Using in [Visul Studio projects](https://github.com/cepthomas/LuaInterop/tree/main/CppCli).

See `C:\Dev\Libs\LuaBagOfTricks\test\test_debugex.lua` for example.

Caveats:
- Plain lua 5.2+ only.
- Apparently doesn't handle being reentrant due to coroutines.
- You can't add breakpoints to a running program or remove them - must use dbg().

