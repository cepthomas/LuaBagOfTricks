---@diagnostic disable: unused-function, unused-local
local ut = require('lbot_utils')
local sx = require('stringex')


-- TODOL >>> https://www.sublimetext.com/docs/build_systems.html#advanced-example


-------------------- A sandbox ------------------------


-- ?? organize modules/globals: https://www.lua.org/pil/15.4.html
-- pl import/require
-- require 'pl' -- calls Penlight\lua\pl\init.lua
-- utils.import 'pl.func' -- take a table/module and 'inject' it into the local namespace.
-- local ops = require 'pl.operator' -- normal import
-- local List = require 'pl.List' -- class
-- local append, concat = table.insert, table.concat -- aliases
-- local optable = ops.optable -- alias
-- ?? add init.lua file? see http://www.playwithlua.com/?p=64
-- -- check the name before the assignment.
-- function M.check_open_package(name) -->> check_global_name?
--  for n, v in pairs(name) do
--      if _G[n] ~= nil then
--          error("name clash: " .. n .. " is already defined")
--      end
--      _G[n] = v
--  end
-- end


-- globals:
-- - basic: _G, _VERSION, assert, collectgarbage, dofile, error, getmetatable, ipairs, load, loadfile, next, pairs, pcall, print,
--     rawequal, rawget, rawlen, rawset, require, select, setmetatable, tonumber, tostring, type, warn, xpcall
-- - modules: coroutine, debug, io, math, os, package, string, table, utf8, 
-- - metamethods: __add, __band, __bnot, __bor, __bxor, __call, __close, __concat, __div, __eq, __gc, __idiv, __index, 
--     __le, __len, __lt, __metatable, __mod, __mode, __mul, __name, __newindex, __pairs, __pow, __shl, __shr, __sub,
--     __tostring, __unm

-- Guarding against typos
-- Indexing into a table in Lua gives you nil if the key isn't present, which can cause errors that are difficult to trace!
-- Our other major use case for metatables is to prevent certain forms of this problem. For types that act like enums, we can carefully apply an __index metamethod that throws:
-- local MyEnum = {
--     A = "A",
--     B = "B",
--     C = "C",
-- }
-- setmetatable(MyEnum, {
--     __index = function(self, key)
--         error(string.format("%q is not a valid member of MyEnum",
--             tostring(key)), 2)
--     end,
-- })
-- Since __index is only called when a key is missing in the table, MyEnum.A and MyEnum.B will still give you back the expected values, but MyEnum.FROB will throw, hopefully helping engineers track down bugs more easily.


--[[ ? args can be
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




--[[ 
-- ?? TODOL Create classes like this:

-- instance table - data goes here
local my_class = {}

-- class table - functions go in here
local MyClass = {}

function MyClass:some_method()
   -- code
end

function MyClass:another_one()
   self:some_method()
   -- more code
end

function my_class.new()
   local self = {}
   setmetatable(self, { __index = MyClass })
   return self
end

return my_class

------------------------------------------
or  Typically what you do, though, is put all of a classes methods into a class object, then set that as the
-- metatable of an instance object. Reusing your example:
local theClass = {}
theClass.__index = theClass

function theClass:func()
    self.property = 12
end

function newObject()    
    local o = {}
    local privateData = "Data"
    return setmetatable(o, theClass)
end
]]



-- ?? TODOL Create classes like this:

-- instance table - data goes here
local _table_ex = {}

-- class table - functions go in here
local Tableex_X = {}

-- meta for _table_ex, indexes go to class

-- __index: The indexing access operation table[key]. This event happens when table is not a table or when key is 
-- not present in table. The metavalue is looked up in the metatable of table. 
-- The metavalue for this event can be either a function, a table, or any value with an __index metavalue.
-- If it is a function, it is called with [table and key as arguments], and the result of the call (adjusted to one value) 
-- is the result of the operation. Otherwise, the final result is the result of indexing this metavalue with key. 
-- This indexing is regular, not raw, and therefore can trigger another __index metavalue. 

local mt =
{
    -- name = name or 'no_name',
    class = 'Tableex_X',
    __index = Tableex_X,
    __newindex = Tableex_X,
    __tostring = function(self) return string.format('%s:(%s:%s)[%d] "%s"',
                    self:class(), self:key_type(), self:value_type(), self:count(), self:name()) end,
    -- __call = function(...) print('__call', ...) end,
}

------------- the class -------------
function Tableex_X:some_method(val)
    print('>>> some_method', val, ut.dump_table(_table_ex, 't111'))
    -- code
end

function Tableex_X:another_one(val)
    print('>>> another_one', val)
    self:some_method(val)
    -- more code
end

------------- instantiate -------------
function _table_ex.new(t, name)
    local self = {}

    setmetatable(self, mt)

   return self
end

return _table_ex

