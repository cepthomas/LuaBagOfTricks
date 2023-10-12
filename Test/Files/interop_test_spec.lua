
-- TODOGEN extra include/using.
-- TODOGEN required?

-- TODOGEN ARGS: boolean int number string intlist numberlist stringlist   RETURN: boolean int number string table

export_lua_funcs = --host_calls_lua =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "interop_HostCallLua",
        description = "booga",
        args =
        {
            {
                name = "arg_one",
                type = "string",
                required = true, -- TBD
                description = "some strings"
            },
            {
                name = "arg_two",
                type = "integer",
                required = true,
                description = "a nice integer"
            },
            {
                name = "arg_three",
                type = "dictionary",
                required = true,
                description = "3 ddddddddd"
            },
        },
        ret =
        {
            type = "table",
            description = "a returned thing"
        }
    },
    {
        -- next function
    }
}


-- TODOGEN ARGS: boolean int number string table   RETURN: boolean int number string table

export_host_funcs = --lua_calls_host =
{
    {
        lua_func_name = "my_lua_func",
        host_func_name = "interop_LuaCallHost",
        work_func = "interop_LuaCallHost_work", -- gets passed the args and ret below
        description = "fooga",

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
                description = "2 ttttttttt"
            },
        },
        ret =
        {
            type = "number",
            description = "a returned thing again"
        }
    },
    {
        -- next function
    }
}
