

host_calls_lua =
{
    description = "booga",
    lua_func_name = "my_lua_func",
    host_func_name = "HostCallLua",
    args =
    {
        {
            name = "arg_one",
            type = "string",
            required = true,
            description = "1 rererere"
        },
        {
            name = "arg_two",
            type = "integer",
            required = true,
            description = "2 rererere"
        },
        {
            name = "arg_three",
            type = "table",
            required = true,
            description = "3 rererere"
        },
    },
    ret =
    {
        type = "table",
        description = "a returned thing"
    },
}

lua_calls_host =
{
    description = "fooga",
    lua_func_name = "my_lua_func",
    host_func_name = "LuaCallHost",
    work_func = "LuaCallHost_work",



    args =
    {
        {
            name = "arg_one",
            type = "integer",
            required = true,
            description = "1 rererere"
        },
        {
            name = "arg_two",
            type = "string",
            required = true,
            description = "2 rererere"
        },
    },
    ret =
    {
        type = "table",
        description = "a returned thing again"
    },
}
