-- Spec to gen C# interop code.
-- All description and args fields are optional.
-- A return value is required, even if just a dummy.
-- Supported data types: B->bool  I->int  N->double  S->string T->TableEx


local M = {}

M.config =
{
    lua_lib_name = "gen_lib",             -- -> lua lib name
    namespace = "MyLuaInteropLib",        -- -> C# namespace
    class = "MyClass",                    -- -> C# using
    add_refs = { "System.Diagnostics", }, -- -> using (optional)
}

-- Host calls script.
M.script_funcs =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "MyLuaFunc",
        required = "true",
        description = "Tell me something good.",
        args =
        {
            {
                name = "arg_one",
                type = "S",
                description = "some strings"
            },
            {
                name = "arg_two",
                type = "I",
                description = "a nice integer"
            },
            {
                name = "arg_three",
                type = "T",
            },
        },
        ret =
        {
            type = "T",
            description = "a returned thing"
        }
    },

    {
        lua_func_name = "my_lua_func2",
        host_func_name = "MyLuaFunc2",
        required = "true",
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
        required = "true",
        description = "no_args",
        ret =
        {
            type = "N",
            description = "a returned number"
        },
    },

    {
        lua_func_name = "optional_func",
        host_func_name = "OptionalFunc",
        required = "false",
        description = "Function is optional.",
        ret =
        {
            type = "I",
            description = "Dummy return value."
        }
    },

}

-- Script calls host.
M.host_funcs =
{
    {
        lua_func_name = "my_lua_func3",
        host_func_name = "MyLuaFunc3",
        description = "fooga",
        args =
        {
            {
                name = "arg_one",
                type = "N",
                description = "kakakakaka"
            },
        },
        ret =
        {
            type = "B",
            description = "required return value"
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
