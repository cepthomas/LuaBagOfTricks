local M = {}

-- host calls lua 
-- ARGS: boolean-! integer-X number-! string-X tableex-X
-- RETURN: boolean-! integer-! number-! string-! tableex-X
M.lua_export_funcs =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "interop_HostCallLua",
        description = "booga",
        args =
        {
            { name = "arg_one", type = "string", description = "some strings" },
            { name = "arg_two", type = "integer", description = "a nice integer" },
            { name = "arg_three", type = "tableex", description = "3 ddddddddd" },
        },
        ret = { type = "tableex", description = "a returned thing" }
    },
    {
        -- next function
    }
}

-- lua calls host - same as above + work_func
-- ARGS: boolean-? integer-X number-! string-X tableex-!
-- RETURN: boolean-! integer-! number-X string-! tableex-?
M.host_export_funcs = 
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "interop_LuaCallHost",
        work_func = "interop_LuaCallHost_work", -- host_export only: gets passed the args and ret below
        description = "fooga",
    }
}

return M
