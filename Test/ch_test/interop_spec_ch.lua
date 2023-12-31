-- Spec to gen C interop code.
-- All description and args fields are optional.
-- A return value is required, even if just a dummy.
-- Supported data types: B->bool  I->int  N->double  S->char*

local M = {}

M.config =
{
    lua_lib_name = "gen_lib",       -- -> lua lib name
    add_refs = { "\"another.h\"" }, -- -> #include
}

M.lua_export_funcs =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "MyLuaFunc",
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
                type = "I",
            },
        },
        ret =
        {
            type = "I",
            description = "a returned thing"
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
