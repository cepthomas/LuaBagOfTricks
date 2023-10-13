
-- TODOGEN extra include/using.
-- TODOGEN required flag?


-- host_calls_lua 
-- ARGS: boolean-! integer-X number-! string-X tableex-X integerlist-! numberlist-! stringlist-!
-- RETURN: boolean-! integer-! number-! string-! tableex-X

export_lua_funcs =
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
                type = "tableex",
                required = true,
                description = "3 ddddddddd"
            },
        },
        ret =
        {
            type = "tableex",
            description = "a returned thing"
        }
    },
    {
        -- next function
    }
}

-- lua_calls_host
-- ARGS: boolean-? integer-X number-! string-X tableex-? integerlist-? numberlist-? stringlist-?
-- RETURN: boolean-! integer-! number-X string-! tableex-?
export_host_funcs =
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
