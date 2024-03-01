-- Spec to gen C interop code.
-- All description and args fields are optional.
-- A return value is required, even if just a dummy.
-- Supported data types: B->bool  I->int  N->double  S->char*

local M = {}

M.config =
{
    lua_lib_name = "gen_lib",       -- -> lua lib name
}

-- Host calls script.
M.script_funcs =
{
    {
        lua_func_name = "calculator",
        host_func_name = "Calculator",
        description = "Simple caalculations.",
        args =
        {
            {
                name = "op_one",
                type = "N",
                description = "Operand 1."
            },
            {
                name = "oper",
                type = "S",
                description = "Operator: + - * /"
            },
            {
                name = "op_two",
                type = "N",
                description = "Operand 2."
            },
        },
        ret =
        {
            type = "N",
            description = "The answer"
        }
    },

    {
        lua_func_name = "day_of_week",
        host_func_name = "DayOfWeek",
        description = "String to integer.",
        args =
        {
            {
                name = "day",
                type = "S",
                description = "The day name."
            },
        },
         ret =
        {
            type = "I",
            description = "The answer."
        }
    },

    {
        lua_func_name = "first_day",
        host_func_name = "FirstDay",
        description = "Function with no args.",
        ret =
        {
            type = "S",
            description = "Day name."
        },
    },

    {
        lua_func_name = "invalid_func",
        host_func_name = "InvalidFunc",
        description = "Function not implemented in script.",
        ret =
        {
            type = "B",
            description = "Required dummy return value."
        }
    },

    {
        lua_func_name = "invalid_arg_type",
        host_func_name = "InvalidArgType",
        description = "Function argument type incorrect.",
        args =
        {
            {
                name = "arg1",
                type = "S",
                description = "The arg."
            },
        },
         ret =
        {
            type = "B",
            description = "Required dummy return value."
        }
    },

    {
        lua_func_name = "invalid_ret_type",
        host_func_name = "InvalidRetType",
        description = "Function return type incorrect.",
        ret =
        {
            type = "I",
            description = "Required dummy return value."
        }
    },

    {
        lua_func_name = "error_func",
        host_func_name = "ErrorFunc",
        description = "Function that calls error().",
        args =
        {
            {
                name = "flavor",
                type = "I",
                description = "Tweak behavior."
            },
        },
        ret =
        {
            type = "B",
            description = "Required dummy return value."
        }
    },
}

-- Script calls host.
M.host_funcs =
{
    {
        lua_func_name = "log",
        host_func_name = "Log",
        description = "Record something for me.",
        args =
        {
            {
                name = "level",
                type = "I",
                description = "Log level."
            },
            {
                name = "msg",
                type = "S",
                description = "What to log."
            },
        },
        ret =
        {
            type = "B",
            description = "Required dummy return value."
        }
    },
    {
        lua_func_name = "get_environment",
        host_func_name = "GetEnvironment",
        description = "How hot are you?",
        args =
        {
            {
                name = "temp",
                type = "N",
                description = "Temperature."
            },
        },
        ret =
        {
            type = "S",
            description = "String environment."
        }
    },
    {
        lua_func_name = "get_timestamp",
        host_func_name = "GetTimestamp",
        description = "Milliseconds.",
        ret =
        {
            type = "I",
            description = "The time."
        }
    },
    {
        lua_func_name = "force_error",
        host_func_name = "ForceError",
        description = "Raise an error from lua code.",
        ret =
        {
            type = "B",
            description = "Required dummy return value."
        }
    },
}

return M
