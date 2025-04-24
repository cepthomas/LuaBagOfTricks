-- A typed list class in the lua prototype style with homogenous values.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.

local ut = require("lbot_utils")
local lt = require("lbot_types")
local sx = require("stringex")
local tx = require('tableex')


-- The global class.
local List = {}


-------------------------------------------------------------------------
--- Create a List. It's a factory.
-- @param name optional name
-- @return a new List object
-- function List:new(t, name)
function List.new(name)
    -- The instance with real data.
    local ll = {}


    -- continue init
    local mt =
    {
        -- Private fields.
        class = 'List',
        name = name,
        value_type='nil',
        -- Metatable.
        __index = List,
        __tostring = function(t)
            local mt = getmetatable(t)
            return string.format('%s(%s)[%s]', mt.name, mt.class, mt.value_type)
        end,
        __newindex = function(t, index, value) rawset(t, index, value) end
    }
    setmetatable(ll, mt)


    return ll
end
-------------------------------------------------------------------------
--- Create a List. It's a factory.
-- @param t array-like table to init the List, or nil for deferred
-- @param name optional name
-- @return a new List object
-- function List:new(t, name)
-- function List.new_orig(t, name)
--     -- The instance with real data.
--     if t ~= nil then
--         lt.val_table(t)
--     end

--     local ll = {}

--     -- Check that the table is array-like.
--     -- Are all keys indexes.
--     local num = 0
--     for k, _ in pairs(t) do
--         if not lt.is_integer(k) then error('All indexes must be integer') end
--         num = num + 1
--     end
--     -- Are they sequential from 1.
--     for i = 1, num do
--         if t[i] == nil then error('All indexes must be sequential') end
--     end

--     -- continue init
--     local mt =
--     {
--         -- Private fields.
--         class = 'List',
--         name = name,
--         value_type='nil',
--         -- Metatable.
--         __index = List,
--         __tostring = function(t)
--             local mt = getmetatable(t)
--             return string.format('%s(%s)[%s]', mt.name, mt.class, mt.value_type)
--         end,
--         __newindex = function(t, index, value) rawset(t, index, value) end
--     }
--     setmetatable(ll, mt)


--     -- Copy the data. This tests for value homogenity.
--     ll:add_range(t)
--     -- for _, v in ipairs(t) do ll:add(v) end

--     return ll
-- end


------------------------ Properties -------------------------------------

function List:name() return getmetatable(self).name end
function List:class() return getmetatable(self).class end
function List:value_type() return getmetatable(self).value_type end


------------------------- Private ---------------------------------------

-------------------------------------------------------------------------
--- Check type of value. Also does lazy init. Raises error.
-- @param v the value to check
function List:_check_val(v)
    local check_vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

    if self.count(self) == 0 then
        -- new object, check types
        local val_types = { 'number', 'integer', 'string', 'boolean', 'table', 'function' }
        local vtype = nil

        for _, v in ipairs(val_types) do
            if v == check_vtype then vtype = check_vtype end
        end

        if vtype ~= nil then
            local mt = getmetatable(self)
            mt.value_type = vtype
            setmetatable(self, mt)
        else
            error('Invalid value type: '..check_vtype)
        end

    else -- request to add to existing
        if check_vtype ~= self:value_type() then error('Values not homogenous '..check_vtype) end
    end
end


------------------------- Public ----------------------------------------

-------------------------------------------------------------------------
--- Diagnostic.
-- @return a string
function List:dump()
    local res = {}
    table.insert(res, tostring(self))
    for _, v in ipairs(self) do
        table.insert(res, tostring(v))
    end
    return sx.strjoin(',', res)
end

-------------------------------------------------------------------------
--- How many.
-- @return the count
function List:count()
    return #self
end

-------------------------------------------------------------------------
--- Copy from an existing list.
-- @param i index of start element, or nil means all aka clone
-- @param count how many, or nil means end
-- @return the new List
function List:get_range(i, count)
    local ls = {}

    local first
    local last
    if i == nil then
        first = 1
        last = #self
    elseif count == nil then
        first = i
        last = #self
    else
        first = i
        last = first + count - 1
    end

    for ind = first, last do
        table.insert(ls, self[ind])
    end

    return self.new(self)
end

-------------------------------------------------------------------------
--- Add an item to the end of the list.
-- @param v the item/value
function List:add(v)
    self._check_val(self, v)
    table.insert(self, v)
end

-------------------------------------------------------------------------
--- Extend the list by appending all the items in the given list.
-- @param other List to append
function List:add_range(other)

    lt.val_table(other, 1)
    for _, v in ipairs(other) do
        self._check_val(self, v)
        table.insert(self, v)
    end
    -- for i = 1, #other do
    --     List:_check_val(other[i])
    --     table.insert(self, other[i])
    -- end
end

-------------------------------------------------------------------------
--- Insert an item at a given position. i is the index of the element before which to insert.
-- @int i index of element before which to insert
-- @param v the item/value
function List:insert(i, v)
    lt.val_integer(i, 1, #self)
    self._check_val(self, v)
    table.insert(self, i, v)
end

-------------------------------------------------------------------------
--- Remove an element given its index.
-- @int i the index
function List:remove_at(i)
    lt.val_integer(i, 1, #self)
    table.remove(self, i)
end

-------------------------------------------------------------------------
--- Remove the first value from the list.
-- @param v data value
function List:remove(v)
    lt.val_not_nil(v)
    for i = 1, #self do
        if self[i] == v then table.remove(self, i) return self end
    end
 end

-------------------------------------------------------------------------
--- Return the index in the list of the first item whose value is given.
-- @param index
-- @param v data value
-- @int i where to start search, nil means beginning
-- @return the index, or nil if not found
function List:index_of(v, i)
    lt.val_not_nil(v)
    i = i or 1
    if i < 0 then i = #self + i + 1 end
    for ind = i, #self do
        if self[ind] == v then return ind end
    end
    return nil
end

-------------------------------------------------------------------------
--- Does list contain value.
-- @param v data value
-- @return bool
function List:contains(v)
    lt.val_not_nil(v)
    local res = self.find(self, v)
    return res ~= nil
    -- return List:find(v) ~= nil or false
    -- return List:find(v) ~= nil  --and true or false
end

-------------------------------------------------------------------------
--- Sort the items of the list in place.
-- @param cmp comparison function, or simple ascending if nil
function List:sort(cmp)
    lt.val_func(cmp)
    if not cmp then cmp = function(a, b) return b < a end end
    table.sort(self, cmp)
end

-------------------------------------------------------------------------
--- Reverse the elements of the list, in place.
function List:reverse()
    local tr = self
    local n = #tr
    for i = 1, n / 2 do
        tr[i], tr[n] = tr[n], tr[i]
        n = n - 1
    end
end

-------------------------------------------------------------------------
--- Empty the list.
function List:clear()
    for _ = 1, #self do table.remove(self) end
end

-------------------------------------------------------------------------
--- Return the index of a value in a list.
-- @param v the value
-- @param start where to start
-- @return index of value, or nil if not found
function List:find(v, start)
    lt.val_type(v, self.value_type(self))
    start = start or 1
    lt.val_integer(start)
    local res = nil

    for idx = start, #self do
        if self[idx] == v then
            res = idx
            break
        end
    end
    return res
end

-------------------------------------------------------------------------
--- Create a list of all elements which match a function.
-- @param func a boolean function
-- @return List object of results
function List:find_all(func)
    lt.val_func(func)
    local ls = {}
    local k = 1
    for i = 1, #self do
        local v = self[i]
        if func(v) then
            ls[k] = v
            k = k + 1
        end
    end

    local res = List:new()
print(tx.dump_table(ls))
    res.add_range(ls)
    return res
end

-------------------------------------------------------------------------
return List
