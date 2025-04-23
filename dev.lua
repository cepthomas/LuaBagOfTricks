---@diagnostic disable: unused-function, unused-local
local ut = require('lbot_utils')
local sx = require('stringex')


-- TODOL >>> https://www.sublimetext.com/docs/build_systems.html#advanced-example


-------------------- A sandbox ------------------------

--[[
?? organize modules/globals: https://www.lua.org/pil/15.4.html
pl import/require
require 'pl' -- calls Penlight\lua\pl\init.lua
utils.import 'pl.func' -- take a table/module and 'inject' it into the local namespace.
local ops = require 'pl.operator' -- normal import
local List = require 'pl.List' -- class
local append, concat = table.insert, table.concat -- aliases
local optable = ops.optable -- alias
?? add init.lua file? see http://www.playwithlua.com/?p=64
-- check the name before the assignment.
function M.check_open_package(name) -->> check_global_name?
 for n, v in pairs(name) do
     if _G[n] ~= nil then
         error("name clash: " .. n .. " is already defined")
     end
     _G[n] = v
 end
end


globals:
- basic: _G, _VERSION, assert, collectgarbage, dofile, error, getmetatable, ipairs, load, loadfile, next, pairs, pcall, print,
    rawequal, rawget, rawlen, rawset, require, select, setmetatable, tonumber, tostring, type, warn, xpcall
- modules: coroutine, debug, io, math, os, package, string, table, utf8, 
- metamethods: __add, __band, __bnot, __bor, __bxor, __call, __close, __concat, __div, __eq, __gc, __idiv, __index, 
    __le, __len, __lt, __metatable, __mod, __mode, __mul, __name, __newindex, __pairs, __pow, __shl, __shr, __sub,
    __tostring, __unm

Guarding against typos
Indexing into a table in Lua gives you nil if the key isn't present, which can cause errors that are difficult to trace!
Our other major use case for metatables is to prevent certain forms of this problem. For types that act like enums, we can carefully apply an __index metamethod that throws:
local MyEnum = {
    A = "A",
    B = "B",
    C = "C",
}
setmetatable(MyEnum, {
    __index = function(self, key)
        error(string.format("%q is not a valid member of MyEnum",
            tostring(key)), 2)
    end,
})
Since __index is only called when a key is missing in the table, MyEnum.A and MyEnum.B will still give you back the expected values, but MyEnum.FROB will throw, hopefully helping engineers track down bugs more easily.


 ? args can be
--   - utils.on_error 'quit'
--   - utils.on_error('quit')
--   - utils.on_error'quit'  ??
local function myfunc( ... )
    -- body
end


local function UT_RAISES(func, args, exp_msg)
    local pass = true
    -- M.num_cases_run = M.num_cases_run + 1

    -- print(args, #args)

    print(table.unpack(args))
    -- local xx = args:unpack()

    local ok, msg = pcall(func, table.unpack(args))

    -- print('!!!', ok, msg) -- T

    if ok then
        print('fail: function did not raise error()')
        pass = false
    elseif sx.contains(msg, exp_msg) then
        print('pass')
        pass = true
    else
        print('fail: function did raise error() but ['..msg..'] does not contain ['..exp_msg..']')
    end
    return pass
end
-- test
-- UT_RAISES(List, { 'muffin', 123, 'beetlejuice', 'tigger' }, '')


-----------------------------------------------
TODOF switch/pattern matching ----------------------
-- https://stackoverflow.com/questions/37447704
-- http://lua-users.org/wiki/SwitchStatement

-- -- Define a switch pattern like:  
-- switch_def(day, month, year, dtype)
-- case (0,  'jan', >= 2020, _):        print('happy new year '..year)
-- case (0,  _,     _,      _,):        print('a new month not '..month)
-- case (15, _,     _,      _,):        print('time to clean the house')
-- case (22, _,     _,      'integer'): print('time to clean the house')
-- default:        print('just another day')
-- (_,  _,     _,      _,):        print('just another day')
-- -- A return value? from function?

-- day == 0, month == 'jan', year >= 2020, print('happy new year '..year)
-- day == 0, month ~= 'jan', print('a new month not '..month)
-- day == 15, print('time to clean the house')
-- day == 22, dtype == 'integer', print('time to clean the house')
-- default, print('just another day')

-- Run it through template (or ?) which produces:
local function switch_run(day, month, year, dtype)
    if day == 0 and month == 'jan' and year >= 2020 then
        print('happy new year')
    elseif day == 0 and month ~= 'jan' then
        print('a new month')
    elseif day == 15 then
        print('clean the house')
    elseif day == 22 and dtype == 'integer' then
        print('clean the house')
    else -- default
        print('just another day')
    end
end
]]

---------------------------------- simple objects ------------------------------
require('List')

-- >>>>>>>>>>>>>>>>>> https://www.lua.org/pil/16.1.html
-- >>>>>>>>>>>>>>>>>> https://www.reddit.com/r/lua/comments/tia21g/comment/i1dok2a/
-- http://lua-users.org/wiki/SimpleLuaClasses



-- 100000
-- start   81.423828125
-- Account1 took   28051.73046875  28133.154296875
-- Account2 took   43119.7578125   71252.912109375
-- GC took -70167.904296875    1085.0078125

-- 10000
-- start   81.408203125
-- Account1 took   2815.6630859375 2897.0712890625  >>> 288 bytes per
-- Account2 took   4290.6640625    7187.7353515625  >>> 439 bytes per
-- GC took -6998.7431640625    188.9921875


-----------------------------------------------------------------------
-- Version using shared metatable and klunky '_P' table holding private fields. 288 bytes per.
Account1 = { }
Account1.__index = Account1
Account1.__tostring = function(t) return string.format('[%s:%s:%d]', t:class(), t:name(), t.balance) end
Account1.__newindex = function(t, index, value) rawset(t, index, value) end
-- Account1.__newindex = function(t, index, value) error('__newindex not supported') end

function Account1:create(name, balance)
    local o = {}

    local p =
    {
        class='Account1',
        name=name,
        -- __index = Account1,
        -- __metatable = Account1
    }
    o._P = p

    -- ? getmetatable(object)
    -- If object does not have a metatable, returns nil.
    -- Else if the object's metatable has a __metatable field, returns the associated value.
    -- Else returns the metatable of the given object. 

    -- make Account1 handle lookup
    setmetatable(o, Account1)

    -- Real data.
    o.balance = balance
    return o
end

function Account1:withdraw(amount)
    self.balance = self.balance - amount
end

function Account1:getbalance()
    return self.balance
end

function Account1:name()
    return self._P.name
end

function Account1:class()
    return self._P.class
end



-----------------------------------------------------------------------
-- Version using individual metatables holding private fields. 439 bytes per.
Account2 = { }

function Account2:create(name, balance)
    local o = {}

    local mt = 
    {
        class = 'Account2',
        name = name,
        __index = Account2,
        __tostring = function(t) return string.format('[%s:%s:%d]', getmetatable(t).class, getmetatable(t).name, t.balance) end,
        __newindex = function(t, index, value) rawset(t, index, value) end
    }
    setmetatable(o, mt)

    -- Real data.
    o.balance = balance
    return o
end

function Account2:withdraw(amount)
    self.balance = self.balance - amount
end

function Account2:getbalance()
    return self.balance
end

function Account2:name()
    return getmetatable(self).name
end

function Account2:class()
    return getmetatable(self).class
end


