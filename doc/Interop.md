# Interop

Tools to generate interop glue code for embedding Lua in various host languages:
- C: Bog standard using factory Lua C API.
- CppCli: Creates a .NET assembly for consumption by host.
- Csh: Call directly from .NET using [KeraLuaEx](https://github.com/cepthomas/KeraLuaEx.git).


C# and/or C code is generated using `gen_interop.lua`, `interop_<flavor>.lua`, and a custom `interop_spec.lua`
file that describes the bidirectional api you need for your application.

`interop_spec.lua` is a plain Lua data file. It has thrree sections:
  - `M.config` specifies identifiers to be used for artifacts.
  - `M.script_funcs` specifies the script functions the application can call.
  - `M.host_funcs` specifies the application functions the script can call.

```lua
For C:
M.config =
{
    lua_lib_name = "luainterop",    -- for require
}

For CppCli:
M.config =
{
    lua_lib_name = "luainterop",    -- for require
    class_name = "Interop",         -- host filenames
    namespace = "CppCli"            -- host namespace
    add_refs = { "other.h", },      -- for #include (optional)
}

For Csh:
{
    lua_lib_name = "luainterop",            -- for require, also filename
    file_name = "Interop",                  -- host filename
    namespace = "Csh",                      -- host namespace
    class_name = "App",                     -- host classname
    add_refs = { "System.Diagnostics", },   -- for using (optional)
}

------------------------ Host => Script ------------------------
M.script_funcs =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "MyLuaFunc",
        required = "true",
        description = "Tell me something good.",
        args =
        {
            { name = "arg_one", type = "S", description = "some strings" },
            { name = "arg_two", type = "I", description = "a nice integer" },
        },
        ret = { type = "T", description = "a returned thing" }
    },
}

------------------------ Script => Host ------------------------
M.host_funcs =
{
    {
        lua_func_name = "log",
        host_func_name = "Log",
        description = "Script wants to log something.",
        args =
        {
            { name = "level", type = "I", description = "Log level" },
            { name = "msg", type = "S", description = "Log message" },
        },
        ret = { type = "I", description = "Unused" }
    },
}
```

This is turned into the flavors of interop code using a command like:
```
lua gen_interop.lua -csh input_dir\interop_spec.lua output_dir
```

Currently the supported api data types are limited to boolean, integer, number, string.
The Csh flavor has an experimental table implementation.

Comprehensive examples are provided in  [LuaBagOfTricks Implementation](https://github.com/cepthomas/LbotImpl.git).

