-- Test script.



local gen = require("gen_lib") -- lua-C api

local script_cnt = 0

local days = { "Hamday", "Eggday", "Moonday", "Boogaday" }

-- print("=============== go go go =======================")


--------------------- Lua calls C host -----------------------------------

ts = gen.get_timestamp()

senv = gen.get_environment(27.34)

b = gen.log(1, string.format("I know this: ts:%d env:%s", ts, senv))

--------------------- C host calls Lua -----------------------------------

-----------------------------------------------------------------------------
function calculator(op_one, oper, op_two)
    if oper == "+" then
        return op_one + op_two
    elseif oper == "-" then
        return op_one - op_two
    elseif oper == "*" then
        return op_one * op_two
    elseif oper == "/" then
        return op_one / op_two
    else
        error("Invalid operator "..oper)
    end
end

-----------------------------------------------------------------------------
function day_of_week(day)
    for i, v in ipairs(days) do
        if v == day then
            return i
        end
    end
    return 0
end

-----------------------------------------------------------------------------
function first_day()
    return days[1]
end

-----------------------------------------------------------------------------
function invalid_func_not()
    return 1.23
end

-----------------------------------------------------------------------------
function invalid_arg_type(arg1)
    -- Spec says arg1 is a string, script thinks it is an int.
    print('scr:', arg1)
    print('scr:', arg1 + 5)
    return arg1 + 5
end

-----------------------------------------------------------------------------
function invalid_ret_type()
    -- Spec says ret is an int, script thinks it is a string.
    return 'xyz'
end

-----------------------------------------------------------------------------
function error_func()
    -- gen.call_invalid_func()
    -- ERROR LUA_ERRRUN 102 execute script failed
    -- ...os\Lua\LuaBagOfTricks\test_code\test_code_ch\script7.lua:26: attempt to call a nil value (field 'call_invalid_func')

    return user_lua_func1()
end


----------------------- Internal user lua functions -------------------------

-----------------------------------------------------------------------------
function user_lua_func3()
    error("user_lua_func3() raises error()")

    script_cnt = script_cnt + 1
    -- if script_cnt == 5 then
    --     error("user_lua_func3() raises error()")
    -- end

    return script_cnt
end

-----------------------------------------------------------------------------
function user_lua_func2()
    return user_lua_func3()
end

-----------------------------------------------------------------------------
function user_lua_func1()
    return user_lua_func2()
end

