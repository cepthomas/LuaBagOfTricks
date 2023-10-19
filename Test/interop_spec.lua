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
        host_func_name = "interop_HostCallLua",
        description = "booga",
        args =
        {
            { name = "arg_one", type = "S", description = "some strings" },
            { name = "arg_two", type = "I", description = "a nice integer" },
            { name = "arg_three", type = "T", description = "3 ddddddddd" },
        },
        ret = { type = "T", description = "a returned thing" }
    },
    -- {
    --     -- next function
    -- }
}

-- lua calls host - same as above + work_func TODO1 combine?
M.host_export_funcs = 
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "interop_LuaCallHost",
        work_func = "interop_LuaCallHost_work", -- host_export only: gets passed the args and ret below
        description = "fooga",
        args =
        {

        },
        ret = { type = "B", description = "a returned thing" }
    },
    -- {
    --     -- next function
    -- }
}

return M
