-- Example spec for generating interop test.

-- TODO Combine the two exports? They're similar.

local M = {}

-- Syntax-specific options.
M.config =
{
    -- General
    lib_name = "my_lib",
    -- CS
    namespace = "HeraAndNow",
    class = "SunAndMoon",
    add_using = { "System.Diagnostics", "System.Drawing" },
    -- C
    add_include = { "<errno.h>" },
}


-- Host calls lua.
M.lua_export_funcs =
{
    {
        description = "booga",
        lua_func_name = "my_lua_func",
        host_func_name = "Interop_HostCallLua",
        args =
        {
            { name = "arg_one", type = "S", description = "some strings" },
            { name = "arg_two", type = "I", description = "a nice integer" },
            { name = "arg_three", type = "T", description = "3 ddddddddd" },
        },
        ret = { type = "T", description = "a returned thing" }
    },
    {
        description = "booga2",
        lua_func_name = "my_lua_func2",
        host_func_name = "Interop_HostCallLua2",
        args =
        {
            { name = "arg_one", type = "B", description = "bbbbbbb" },
        },
        ret = { type = "N", description = "a returned number" }
    },
    {
        description = "bad_spec",
        lua_func_name = "bad_spec",
        host_func_name = "Interop_bad_spec",
        ret = { type = "N", description = "a returned number" },
        args =
        {
        },
    },
    -- etc
}

-- Lua calls host.
M.host_export_funcs = 
{
    {
        description = "fooga",
        lua_func_name = "my_lua_func",
        host_func_name = "Interop_MyLuaFunc",
        work_func = "Interop_MyLuaFunc_work", -- Signature is args and ret below.
        args =
        {
            { name = "arg_one", type = "N", description = "kakakakaka" },
        },
        ret = { type = "B", description = "a returned thing" }
    },
    {
        description = "fooga2",
        lua_func_name = "another_lua_func",
        host_func_name = "Interop_AnotherLuaFunc",
        work_func = "Interop_AnotherLuaFunc_work",
        args =
        {
            { name = "arg_one", type = "T", description = "rere reree" },
            { name = "arg_two", type = "S", description = "ssss reree" },
        },
        ret = { type = "N", description = "a returned thing" }
    },
    -- etc
}

return M
