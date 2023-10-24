-- Example spec for generating interop test.

local M = {}

-- Syntax-specific options.
M.config =
{
    -- General
    lua_lib_name = "gen_lib", -- as used by RequireF()
    host_lib_name = "GenLib", -- as used for class / file names - file name => GenLibInterop
    namespace = "MyLib", -- C doesn't really need this
    add_refs =  --OPT cs=using c=include
    {
        "System.Diagnostics",
        -- "System.Drawing",
        -- "<errno.h>",
        -- "something_else.h"
    },
}
 
 
-- Host calls lua.
M.lua_export_funcs =
{
    {
        lua_func_name = "my_lua_func", 
        host_func_name = "MyLuaFunc", 
        description = "booga", --OPT
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
                description = "3 ddddddddd" --OPT
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
        description = "booga2", 
        args = 
        {
            {
                name = "arg_one", 
                type = "B", 
                description = "bbbbbbb" 
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
        description = "no_args", 
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
        lua_func_name = "my_lua_func",
        host_func_name = "MyLuaFunc",
        description = "fooga", --OPT
--!!auto assign        work_func = "MyLuaFuncWork", -- Signature is args and ret below.
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
            description = "a returned thing" --OPT
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
