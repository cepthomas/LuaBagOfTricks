-------------------- A sandbox ------------------------

---@diagnostic disable: unused-function, unused-local
local ut = require('lbot_utils')
local sx = require('stringex')
local tx = require("tableex")
require('List')


-- //---------------- TableEx --------------------------//
-- /// TODO Add tableex type support similar to KeraLuaEx LuaEx.cs/TableEx.cs (see c_emb_lua\source_code\ structinator).
-- //  TODO Consider arrays of scalars or tableex.
-- typedef struct tableex
-- {
--     int something;
--     char* other;
-- } tableex_t;

-- /// Push a table onto lua stack.
-- /// @param[in] l Internal lua state.
-- /// @param[in] tbl The table.
-- void luaex_pushtableex(lua_State* l, tableex_t* tbl);

-- /// Make a TableEx from the lua table on the top of the stack.
-- /// Note: Like other "to" functions except also does the pop.
-- /// @param[in] l Internal lua state.
-- /// @param[in] ind Where it is on the stack. Not implemented yet.
-- /// @return The new table or NULL if invalid.
-- tableex_t* luaex_totableex(lua_State* l, int ind);

---------------------------------------------------------------------------
--[[  Simple objects.
! Need to store private data not exposed by the main table.

- https://www.lua.org/pil/16.1.html
- https://www.reddit.com/r/lua/comments/tia21g/comment/i1dok2a/
- http://lua-users.org/wiki/SimpleLuaClasses
]]

----- Using shared metatable and klunky '_P' table holding private fields.
Account1 = {}
Account1.__index = Account1
Account1.__tostring = function(t) return string.format('[%s:%s:%d]', t:class(), t:name(), t.getbalance()) end
Account1.__newindex = function(t, index, value) rawset(t, index, value) end
-- Account1.__newindex = function(t, index, value) error('__newindex not supported') end

function Account1:new(name, balance)
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


----- Using individual metatables holding private fields.
Account2 = {}
function Account2:new(name, balance)
    local acct = {}
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
    setmetatable(acct, mt)

    -- public data
    acct.balance = balance
    return acct
end

function Account2:name() return getmetatable(self).name end
function Account2:class() return getmetatable(self).class end
function Account2:withdraw(amount) self.balance = self.balance - amount end
function Account2:getbalance() return self.balance end


----- Using closures + some meta.
function Account3(name, balance)
    local acct = {}

    function acct:name() return getmetatable(self).name end
    function acct:class() return getmetatable(self).class end
    function acct:withdraw(amount) self.balance = self.balance - amount end
    function acct:getbalance() return self.balance end

    -- Object has been created. Finish up data initialization.
    setmetatable(acct,
    {
        class = 'Account3',
        name = name or 'no_name',
        __tostring = function(t) return string.format('[%s:%s:%d]', getmetatable(t).class, getmetatable(t).name, t.balance) end,
    })

    -- public data
    acct.balance = balance
    return acct
end


----- Using closures + some meta.
-- Account4 = {}
-- function Account4.new(name, balance)
function Account4(name, balance)
    ----- private
    -- fields
    local _class = 'Account4'
    local _name = name or 'no_name'
    local _balance = balance
    -- private method
    -- local function private_method(arg) _field1 = _field1 + 1 end

    ----- public
    local acct = {}
    -- public field
    -- acct.public_field = "hello"
    -- public method
    -- function acct:method (arg) print('public_field=', acct.public_field) end
    -- public method to access a private field
    -- function acct:get_field1() return _field1 end

    function acct:name() return _name end
    function acct:class() return _class end
    function acct:withdraw(amount) _balance = _balance - amount end
    function acct:getbalance() return _balance end

    local mt =
    {
        --__index = Account4,
        __tostring = function(t) return string.format('[%s:%s:%d]', _class, _name, _balance) end,
        __newindex = function(t, index, value) rawset(t, index, value) end
    }
    setmetatable(acct, mt)

    return acct
end



-- Foo = {}
-- function Foo.new(arg)
function Foo(arg)
    -- private fields
    local field1 = 42
    local field2 = "string"
    -- private method
    local function private_method(parg)  end

    local o = {}
    -- public field
    o.public_field = "hello"
    -- public method
    function o:method(parg)  end
    -- public method to access a private field
    function o:get_field1() return field1 end


    -- local mt = {}
    -- mt.__call = function(...)
    --     local obj = {}
    --     -- ???
    --     return obj
    -- end
    -- setmetatable(o, mt)

    -- return the object
    return o
end



----- run tests
local function test_simple_objects()

--[[
    -- local acct = Account4('bob_name', 1000)
    -- print('00', tx.dump_table(acct, 'acct', 0))

    -- local fff = Foo('aaa')
    -- print('00', tx.dump_table(fff, 'fff', 0))
    -- fff(table):
    --     get_field1(function)[function: 0000000000fea4e0]
    --     public_field(string)[hello]
    --     method(function)[function: 0000000000fea9f0]


    local acct_bob = Account4('bob_name', 1000)
    -- -- client create and use an Account
    print('00', tx.dump_table(acct_bob, 'acct_bob_name', 0))

    print('10', 'bob got:', acct_bob:getbalance())
    acct_bob:withdraw(100)
    print('15', 'bob got:', acct_bob:getbalance())

    acct_bob['added'] = 1234

    print('20', 'acct_bob:', acct_bob)

    print('30', acct_bob:name(), acct_bob, tx.dump_table(acct_bob, acct_bob:name(), 0))

    -- print('I got:', acct_bob:getbalance())

    local acct_mary = Account4('mary_name', 1234)
    print('35', 'mary got:', acct_mary.balance)
    print('40', 'mary got:', acct_mary:getbalance())

    print('45', 'acct_mary:', acct_mary)
    print('50', 'acct_bob:', acct_bob)
]]

    --  Measure object sizes.
    local start_size = collectgarbage('count')
    local store = {}
    local num = 10000
    local current_size = 0

    local function _do_one(func, name)
        for i = 1, num do
            local a = func('bob_'..tostring(i), 1000)
            table.insert(store, a)
        end
        current_size = collectgarbage('count')
        print(name..' bytes: '..tostring((current_size - start_size) * 1024 / num, 10))
        start_size = current_size
    end

    -- _do_one(func, 'Account1')
    -- _do_one(Account2, 'Account2')
    _do_one(Account3, 'Account3')
    _do_one(Account4, 'Account4')

    -- force garbage collection
    store = {}
    current_size = collectgarbage('count')
    print('GC took', current_size - start_size, current_size)
    start_size = current_size

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

