-------------------- A sandbox ------------------------

---@diagnostic disable: unused-function, unused-local
local ut = require('lbot_utils')
local sx = require('stringex')
local tx = require("tableex")
require('List')



---------------------------------------------------------------------------
--[[  Simple objects.
! Need to store private data not exposed by the main table.

- https://www.lua.org/pil/16.1.html
- https://www.reddit.com/r/lua/comments/tia21g/comment/i1dok2a/
- http://lua-users.org/wiki/SimpleLuaClasses
]]

-- Using shared metatable and klunky '_P' table holding private fields. 288 bytes per instance.
Account1 = {}
Account1.__index = Account1
Account1.__tostring = function(t) return string.format('[%s:%s:%d]', t:class(), t:name(), t.balance) end
Account1.__newindex = function(t, index, value) rawset(t, index, value) end
-- Account1.__newindex = function(t, index, value) error('__newindex not supported') end

function Account1:create(name, balance)
    local acc =
    {
        _P =
        {
            class = 'Account1',
            name = name or 'no_name',
            -- __index = Account1,
            -- __metatable = Account1
        }
    }
    setmetatable(acc, Account1)

    -- public data
    acc.balance = balance
    return acc
end

function Account1:name() return self._P.name end
function Account1:class() return self._P.class end
function Account1:withdraw(amount) self.balance = self.balance - amount end
function Account1:getbalance() return self.balance end


-- Using individual metatables holding private fields. 439 bytes per per instance.
Account2 = {}

function Account2:create(name, balance)
    local acc = {}
    local mt =
    {
        -- private info
        class = 'Account2',
        name = name or 'no_name',
        -- class functions
        __index = Account2,
        __tostring = function(t) return string.format('[%s:%s:%d]', getmetatable(t).class, getmetatable(t).name, t.balance) end,
        __newindex = function(t, index, value) rawset(t, index, value) end
    }
    setmetatable(acc, mt)

    -- public data
    acc.balance = balance
    return acc
end

function Account2:name() return getmetatable(self).name end
function Account2:class() return getmetatable(self).class end
function Account2:withdraw(amount) self.balance = self.balance - amount end
function Account2:getbalance() return self.balance end


-- Using closures + some meta, XXX bytes per per instance.
function Account3(name, balance)
    local acc = {}

    function acc:name() return getmetatable(self).name end
    function acc:class() return getmetatable(self).class end
    function acc:withdraw(amount) self.balance = self.balance - amount end
    function acc:getbalance() return self.balance end

    -- Object has been created. Finish up data initialization.
    setmetatable(acc,
    {
        class = 'Account3',
        name = name or 'no_name',
        __tostring = function(t) return string.format('[%s:%s:%d]', getmetatable(t).class, getmetatable(t).name, t.balance) end,
    })

    -- public data
    acc.balance = balance
    return acc
end

local function test_simple_objects()

    local acc = Account1

    -- client create and use an Account
    local acc_bob = acc:create('bob_name', 1000)
    print('10', 'bob got:', acc_bob:getbalance())
    acc_bob:withdraw(100)
    print('15', 'bob got:', acc_bob:getbalance())

    acc_bob['added'] = 1234

    print('20', 'acc_bob:', acc_bob)

    -- print('25', 'acc_bob:', acc_bob, tx.dump_table(acc_bob, 0, 'acc_bob table'))
    print('30', acc_bob:name(), acc_bob, tx.dump_table(acc_bob, 0, acc_bob:name()))

    -- print('I got:', acc_bob:getbalance())

    local acc_mary = acc:create('mary_name', 1234)
    print('35', 'mary got:', acc_mary.balance)
    print('40', 'mary got:', acc_mary:getbalance())

    print('45', 'acc_mary:', acc_mary)
    print('50', 'acc_bob:', acc_bob)


    --  Measure object sizes.
    local start_size = collectgarbage('count')
    print('start', start_size)
    local store = {}
    local num = 10000

    for i = 1, num do
        local a = Account1:create('bob_'..tostring(i), 1000)
        table.insert(store, a)
    end
    local current_size = collectgarbage('count')
    print('Account1 bytes: '..tostring((current_size - start_size) * 1024 / num, 10))
    start_size = current_size

    for i = 1, num do
        local a = Account2:create('bob_'..tostring(i), 1000)
        table.insert(store, a)
    end
    current_size = collectgarbage('count')
    print('Account2 bytes: '..tostring((current_size - start_size) * 1024 / num, 10))
    start_size = current_size

    for i = 1, num do
        local a = Account3('bob_'..tostring(i), 1000)
        table.insert(store, a)
    end
    current_size = collectgarbage('count')
    print('Account3 bytes: '..tostring((current_size - start_size) * 1024 / num, 10))
    start_size = current_size

    -- force garbage collection
    store = {}
    current_size = collectgarbage()

    -- current_size = collectgarbage('count')
    -- print('GC took', current_size - start_size, current_size)
    -- start_size = current_size


end


---------------------------------------------------------------------------
--[[ Guarding against typos
Indexing into a table in Lua gives you nil if the key isn't present, which can cause errors that are difficult to trace!
Our other major use case for metatables is to prevent certain forms of this problem. For types that act like enums,
we can carefully apply an __index metamethod that throws.
Since __index is only called when a key is missing in the table, MyEnum.A and MyEnum.B will still give you back the expected values, but MyEnum.FROB will throw, hopefully helping engineers track down bugs more easily.
]]
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


---------------------------------------------------------------------------
--[[ switch/pattern matching 

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


---------------------------------------------------------------------------
--[[ organize modules/globals: https://www.lua.org/pil/15.4.html

require 'pl' -- calls Penlight\lua\pl\init.lua
utils.import 'pl.func' -- take a table/module and 'inject' it into the local namespace.
local ops = require 'pl.operator' -- normal import
local List = require 'pl.List' -- class
local append, concat = table.insert, table.concat -- aliases
local optable = ops.optable -- alias
--?? add init.lua file? see http://www.playwithlua.com/?p=64
-- check the name before the assignment.
function M.check_open_package(name) -->> check_global_name?
    for n, v in pairs(name) do
        if _G[n] ~= nil then
            error("name clash: " .. n .. " is already defined")
        end
        _G[n] = v
    end
end
]]


---------------------------------------------------------------------------
--[[ pnut helper for error() callers TODOL put in pnut and update tests.
]]

local function case_failed(msg, info) print('FAIL:', msg, info) end

local function UT_RAISES(func, args, exp_msg, info)
    local pass = true
    -- M.num_cases_run = M.num_cases_run + 1
    local ok, msgcall = pcall(func, args)

    if ok then
        local msg = 'function did not raise error()'
        case_failed(msg, info)
        pass = false
    elseif sx.contains(msgcall, exp_msg) then
        pass = true
    else
        local msg = 'function did raise error() but ['..msgcall..'] does not contain ['..exp_msg..']'
        case_failed(msg, info)
        pass = false
    end
    return pass
end


---------------------------------------------------------------------------

-- What to do.

-- test objects
-- test_simple_objects()


-- test UT_RAISES
local function func_that_throws(args, exp_msg)
    local a1, a2, a3, a4 = table.unpack(args)
    if a1 == a2 + a3 + a4 then error("BOOM") end
end

local res = UT_RAISES(func_that_throws, {66, 1, 2, 3}, 'not_exp_msg')
res = UT_RAISES(func_that_throws, {6, 1, 2, 3}, 'BOOM')
res = UT_RAISES(func_that_throws, {6, 1, 2, 3}, 'exp_msg')
