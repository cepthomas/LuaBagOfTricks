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
Generates C# and C code for the standard lua interop. The ``.\Test projects` demonstrate how to use it.

How to define an API:
``` Lua
-- Example spec for generating interop, with doc comments.
-- Supported arg and return value types: B=boolean I=integer N=number S=string T=TableEx.
-- OPT are optional fields.
-- Return type is required, void not supported.
-- The C version needs some more infrastructure to support tables.

local M = {}

-- Syntax-specific options.
M.config =
{
    -- General
    lua_lib_name = "gen_lib", -- as used by luaL_requiref() / RequireF()
    -- C# specific
    namespace = "MyLib",
    class = "MyClass",
    add_refs = -- using
    {
        "System.Diagnostics",
        "OtherAssembly",
    },
    -- C specific
    add_refs = -- #include
    {
        "<errno.h>",
        "<other_stuff.h>",
    },
}

-- Host calls lua.
M.lua_export_funcs =
{
    {
        lua_func_name = "my_lua_func1",
        host_func_name = "MyLuaFunc1",
        description = "Tell me something good.", --OPT
        args = --OPT
        {
            {
                name = "arg_one",
                type = "S",
                description = "some string" --OPT
            },
            {
                name = "arg_two",
                type = "T",
                --description = "missing desc" --OPT
            },
            -- etc for other arguments
        },
        ret =
        {
            type = "N",
            description = "a return value" --OPT
        }
    },
    -- etc for other functions
}

-- Lua calls host.
M.host_export_funcs =
{
    {
        lua_func_name = "my_lua_func2",
        host_func_name = "MyLuaFunc2",
        description = "fooga", --OPT
        args = --OPT
        {
            {
                name = "arg_one",
                type = "N",
                description = "kakakakaka" --OPT
            },
            -- etc for other arguments
        },
        ret =
        {
            type = "T",
            description = "a returned thing" --OPT
        }
    },
    -- etc for other functions
}

return M
```