-- Example spec for generating interop, with doc comments.
-- OPT are optional fields.

local M = {}

-- Syntax-specific options.
M.config =
{
    -- General
    lua_lib_name = "gen_lib", -- as used by luaL_requiref()/RequireF()
    -- Syntax specific
    namespace = "MyLib", -- C# specific
    add_refs =
    {
        "System.Diagnostics",  -- C#: using
        "<errno.h>",           -- C: include
    },
}


-- Host calls lua.
M.lua_export_funcs =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "MyLuaFunc",
        description = "Tell me something good.", --OPT
        args =--OPT
        {
            {
                name = "arg_one",
                type = "S",
                description = "some strings" --OPT
            },
            {
                name = "arg_two",
                type = "I",
                description = "a nice integer" --OPT
            },
            {
                name = "arg_three",
                type = "T",
                --description = "missing desc" --OPT
            },
        },
        ret =
        {
            type = "T",
            description = "a returned thing" --OPT
        }
    },
    {
        lua_func_name = "my_lua_func2",
        host_func_name = "MyLuaFunc2",
        description = "wooga wooga",
        args =
        {
            {
                name = "arg_one",
                type = "B",
                description = "aaa bbb ccc"
            },
        },
         ret =
        {
            type = "N",
            description = "a returned number"
        }
    },
    {
        lua_func_name = "no_args_func",
        host_func_name = "NoArgsFunc",
        description = "function with no args",
        ret =
        {
            type = "N",
            description = "a returned number"
        },
    },
}

-- Lua calls host.
M.host_export_funcs =
{
    {
        lua_func_name = "my_lua_func3",
        host_func_name = "MyLuaFunc3",
        description = "fooga", --OPT
        args = --OPT
        {
            {
                name = "arg_one",
                type = "N",
                description = "kakakakaka" --OPT
            },
        },
        ret =
        {
            type = "B",
            description = "required return value" --OPT
        }
    },
    {
        lua_func_name = "func_with_no_args",
        host_func_name = "FuncWithNoArgs",
        description = "Func with no args",
        ret =
        {
            type = "N",
            description = "a returned thing"
        }
    },
}

return M
