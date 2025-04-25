-- A typed list class in the lua prototype style with homogenous values.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.

local ut = require("lbot_utils")
local lt = require("lbot_types")
local sx = require("stringex")
local tx = require('tableex')


-- The global class.
local M = {}

-------------------------------------------------------------------------
--- Create a List. It's a factory.
-- @param name optional name
-- @return a new List object
function M.new(name)

    -- Private fields
    local _class = 'List'
    local _name = name or 'no_name'
    -- local _balance = balance
    local _value_type = 'nil'

    -- Public instance
    local ll = {}

    ------------------------ Properties -------------------------------------

    function ll:name() return _name end
    function ll:class() return _class end
    function ll:value_type() return _value_type end


    ------------------------- Private ---------------------------------------

    -------------------------------------------------------------------------
    --- Check type of value. Also does lazy init. Raises error.
    -- @param val the value to check
    function ll:_check_val(val)
        local check_vtype = ut.ternary(lt.is_integer(val), 'integer', type(val))

        if self.count(self) == 0 then
            -- new object, check types
            local val_types = { 'number', 'integer', 'string', 'boolean', 'table', 'function' }
            local vtype = nil

            for _, v in ipairs(val_types) do
                if v == check_vtype then vtype = check_vtype end
            end

            if vtype ~= nil then
                _value_type = vtype
            else
                error('Invalid value type: '..check_vtype)
            end

        else -- request to add to existing
            if check_vtype ~= _value_type then error('Values not homogenous: '..check_vtype) end
        end
    end


    ------------------------- Public ----------------------------------------

    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @return a string
    function ll:dump()
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
    function ll:count()
        return #self
    end

    -------------------------------------------------------------------------
    --- Copy from an existing list.
    -- @param i index of start element, or nil means all aka clone
    -- @param count how many, or nil means end
    -- @return table with copied values
    function ll:get_range(i, count)
        local res = {}

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
            table.insert(res, self[ind])
        end

        return res
    end

    -------------------------------------------------------------------------
    --- Add an item to the end of the list.
    -- @param val the item/value
    function ll:add(val)
        self._check_val(self, val)
        table.insert(self, val)
    end

    -------------------------------------------------------------------------
    --- Extend the list by appending all the items in the given list.
    -- @param other table to append
    function ll:add_range(other)
        lt.val_table(other, 1)
        for _, val in ipairs(other) do
            self._check_val(self, val)
            table.insert(self, val)
        end
        -- for i = 1, #other do
        --     ll:_check_val(other[i])
        --     table.insert(self, other[i])
        -- end
    end

    -------------------------------------------------------------------------
    --- Insert an item at a given position. i is the index of the element before which to insert.
    -- @int i index of element before which to insert
    -- @param val the item/value
    function ll:insert(i, val)
        lt.val_integer(i, 1, #self)
        self._check_val(self, val)
        table.insert(self, i, val)
    end

    -------------------------------------------------------------------------
    --- Remove an element given its index.
    -- @int i the index
    function ll:remove_at(i)
        lt.val_integer(i, 1, #self)
        table.remove(self, i)
    end

    -------------------------------------------------------------------------
    --- Remove the first value from the list.
    -- @param val data value
    function ll:remove(val)
        lt.val_not_nil(val)
        for i = 1, #self do
            if self[i] == val then table.remove(self, i) return self end
        end
     end

    -------------------------------------------------------------------------
    --- Return the index in the list of the first item whose value is given.
    -- @param index
    -- @param val data value
    -- @int i where to start search, nil means beginning
    -- @return the index, or nil if not found
    function ll:index_of(val, i)
        lt.val_not_nil(val)
        i = i or 1
        if i < 0 then i = #self + i + 1 end
        for ind = i, #self do
            if self[ind] == val then return ind end
        end
        return nil
    end

    -------------------------------------------------------------------------
    --- Does list contain value.
    -- @param val data value
    -- @return bool
    function ll:contains(val)
        lt.val_not_nil(val)
        local res = self.find(self, val)
        return res ~= nil
        -- return ll:find(val) ~= nil or false
        -- return ll:find(val) ~= nil  --and true or false
    end

    -------------------------------------------------------------------------
    --- Sort the items of the list in place.
    -- @param cmp comparison function, or simple ascending if nil
    function ll:sort(cmp)
        lt.val_func(cmp)
        if not cmp then cmp = function(a, b) return b < a end end
        table.sort(self, cmp)
    end

    -------------------------------------------------------------------------
    --- Reverse the elements of the list, in place.
    function ll:reverse()
        local tr = self
        local n = #tr
        for i = 1, n / 2 do
            tr[i], tr[n] = tr[n], tr[i]
            n = n - 1
        end
    end

    -------------------------------------------------------------------------
    --- Empty the list.
    function ll:clear()
        for _ = 1, #self do table.remove(self) end
    end

    -------------------------------------------------------------------------
    --- Return the index of a value in a list.
    -- @param val the value
    -- @param start where to start
    -- @return index of value, or nil if not found
    function ll:find(val, start)
        lt.val_type(val, self.value_type(self))
        start = start or 1
        lt.val_integer(start)
        local res = nil

        for idx = start, #self do
            if self[idx] == val then
                res = idx
                break
            end
        end
        return res
    end

    -------------------------------------------------------------------------
    --- Create a list of all elements which match a function.
    -- @param func a boolean function
    -- @return table of results
    function ll:find_all(func)
        lt.val_func(func)
        local res = {}
        for i = 1, #self do
            local v = self[i]
            if func(v) then
                res[#res + 1] = v
            end
        end

        return res
    end


    ------------------------- Finish ----------------------------------------

    local mt =
    {
        --__index = List,
        __tostring = function(t) return string.format('%s(%s)[%s]', _name, _class, _value_type) end,
        -- __newindex = function(t, index, value) rawset(t, index, value) end
        -- __newindex = function(t, index, value) error('__newindex not supported') end
    }
    setmetatable(ll, mt)

    return ll
end



-------------------------------------------------------------------------
return M
