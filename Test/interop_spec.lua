local M = {}

-- Options depending on syntax.
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


-- host calls lua 
M.lua_export_funcs =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "Interop_HostCallLua",
        description = "booga",
        args =
        {
            { name = "arg_one", type = "S", description = "some strings" },
            { name = "arg_two", type = "I", description = "a nice integer" },
            { name = "arg_three", type = "T", description = "3 ddddddddd" },
        },
        ret = { type = "T", description = "a returned thing" }
    },
    {
        lua_func_name = "my_lua_func2",
        host_func_name = "Interop_HostCallLua2",
        description = "booga2",
        args =
        {
            { name = "arg_one", type = "B", description = "bbbbbbb" },
        },
        ret = { type = "N", description = "a returned number" }
    },
    {
        lua_func_name = "bad_spec",
        host_func_name = "Interop_bad_spec",
        description = "bad_spec",
        ret = { type = "N", description = "a returned number" }
    },
    -- etc
}

-- lua calls host - same as above + work_func TODO1 combine?
M.host_export_funcs = 
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "Interop_MyLuaFunc",
        work_func = "Interop_MyLuaFunc_work", -- host_export only: gets passed the args and ret below
        description = "fooga",
        args =
        {
            { name = "arg_one", type = "N", description = "kakakakaka" },
        },
        ret = { type = "B", description = "a returned thing" }
    },
    {
        lua_func_name = "another_lua_func",
        host_func_name = "Interop_AnotherLuaFunc",
        work_func = "Interop_AnotherLuaFunc_work", -- host_export only: gets passed the args and ret below
        description = "fooga",
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
