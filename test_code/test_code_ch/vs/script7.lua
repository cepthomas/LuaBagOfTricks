
-- Script for plaaying with log-print-error ideas.


-- TODOT lua-L print => io.write() -- default is stdout, change with io.output()
-- TODOT error(message [, level])  Raises an error (see §2.3) with message as the error object. This function never returns.
-- ... these trickle up to the caller via luaex_docall/lua_pcall return



local gen = require("gen_lib") -- lua api

script_cnt = 0

print("=============== go go go =======================")


--------------------- Lua calls host -----------------------------------
b = gen.my_lua_func3(12.345)
-- gen.my_lua_func3, N arg_one, ret B

n = gen.func_with_no_args()
-- gen.func_with_no_args, ret N


--------------------- Called from C Host -----------------------------------

-----------------------------------------------------------------------------
function my_lua_func(arg_one, arg_two, arg_three)
    -- my_lua_func, S arg_one, I arg_two, I arg_three, ret I
    
    lua_func1()

    if arg_two == 5 then
        error("got triggered!")
    end


    return 999
end


-----------------------------------------------------------------------------
function my_lua_func2(arg_one)
    -- my_lua_func2, B arg_one, ret N

    return 88.88
end

-----------------------------------------------------------------------------
function no_args_func()
    -- no_args_func, ret N

    return 22.22
end

----------------------- User lua functions -------------------------

-----------------------------------------------------------------------------
function lua_func3()
    script_cnt = script_cnt + 1

    if arg_two == 5 then
        error("lua_func3() got triggered! "..)
    end

    return script_cnt
end

-----------------------------------------------------------------------------
function lua_func2()
    return lua_func3()
end

-----------------------------------------------------------------------------
function lua_func1()
    return lua_func2()
end

