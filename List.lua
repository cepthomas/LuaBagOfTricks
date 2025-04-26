-- A typed list class in the lua prototype style with homogenous values.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.

local ut = require("lbot_utils")
local lt = require("lbot_types")
local sx = require("stringex")
local tx = require('tableex')


-- The List class.
local M = {}

-------------------------------------------------------------------------
--- Create a List. It's a factory.
-- @param name optional name
-- @return a new List object
function M.new(name)

    -- Private fields
    local _class = 'List'
    local _name = name or 'no_name'
    local _value_type = 'nil'
    local _data = {}

    -- Instance
    local list = {}

    ------------------------ Properties -------------------------------------

    function list:name() return _name end
    function list:class() return _class end
    function list:value_type() return _value_type end


    ------------------------- Private ---------------------------------------

    -------------------------------------------------------------------------
    --- Check type of value. Also does lazy init. Raises error.
    -- @param val the value to check
    local function _check_val(val)
        local check_vtype = ut.ternary(lt.is_integer(val), 'integer', type(val))

        if tx.table_count(_data) == 0 then
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
            if check_vtype ~= _value_type then error('Values not homogenous: '..check_vtype..' should be '.._value_type) end
        end
    end


    ------------------------- Public ----------------------------------------

    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @return a csv string
    function list:dump()
        return tx.dump_list(_data)
    end

    -------------------------------------------------------------------------
    --- How many.
    -- @return the count
    function list:count()
        return #_data
    end

    -------------------------------------------------------------------------
    --- Copy from an existing list.
    -- @param i index of start element, or nil means all aka clone
    -- @param count how many, or nil means end
    -- @return table with copied values
    function list:get_range(i, count)
        local res = {}

        local first
        local last
        if i == nil then
            first = 1
            last = #_data
        elseif count == nil then
            first = i
            last = #_data
        else
            first = i
            last = first + count - 1
        end

        for ind = first, last do
            table.insert(res, _data[ind])
        end

        return res
    end

    -------------------------------------------------------------------------
    --- Add an item to the end of the list.
    -- @param val the item/value
    function list:add(val)
        _check_val(val)
        table.insert(_data, val)
    end

    -------------------------------------------------------------------------
    --- Extend the list by appending all the items in the given list.
    -- @param other table to append
    function list:add_range(other)
        lt.val_table(other, 1)
        for _, val in ipairs(other) do
            _check_val(val)
            table.insert(_data, val)
        end
    end

    -------------------------------------------------------------------------
    --- Insert an item at a given position. i is the index of the element before which to insert.
    -- @int i index of element before which to insert
    -- @param val the item/value
    function list:insert(i, val)
        lt.val_integer(i, 1, #_data)
        _check_val(val)
        table.insert(_data, i, val)
    end

    -------------------------------------------------------------------------
    --- Remove an element given its index.
    -- @int i the index
    function list:remove_at(i)
        lt.val_integer(i, 1, #_data)
        table.remove(_data, i)
    end

    -------------------------------------------------------------------------
    --- Remove the first value from the list.
    -- @param val data value
    function list:remove(val)
        lt.val_not_nil(val)
        for i = 1, #_data do
            if _data[i] == val then table.remove(_data, i) end
        end
     end

    -------------------------------------------------------------------------
    --- Return the index in the list of the first item whose value is given.
    -- @param index
    -- @param val data value
    -- @int i where to start search, nil means beginning
    -- @return the index, or nil if not found
    function list:index_of(val, i)
        lt.val_not_nil(val)
        i = i or 1
        if i < 0 then i = #_data + i + 1 end
        for ind = i, #_data do
            if _data[ind] == val then return ind end
        end
        return nil
    end

    -------------------------------------------------------------------------
    --- Does list contain value.
    -- @param val data value
    -- @return bool
    function list:contains(val)
        lt.val_not_nil(val)
        for idx = 1, #_data do
            if _data[idx] == val then return true end
        end
        return false
    end

    -------------------------------------------------------------------------
    --- Sort the items of the list in place.
    -- @param cmp comparison function, or simple ascending if nil
    function list:sort(cmp)
        lt.val_func(cmp)
        if not cmp then cmp = function(a, b) return b < a end end
        table.sort(_data, cmp)
    end

    -------------------------------------------------------------------------
    --- Reverse the elements of the list, in place.
    function list:reverse()
        local tr = _data
        local n = #tr
        for i = 1, n / 2 do
            tr[i], tr[n] = tr[n], tr[i]
            n = n - 1
        end
    end

    -------------------------------------------------------------------------
    --- Empty the list.
    function list:clear()
        for _ = 1, #_data do table.remove(_data) end
    end

    -------------------------------------------------------------------------
    --- Return the index of a value in a list.
    -- @param val the value
    -- @param start where to start
    -- @return index of value, or nil if not found
    function list:find(val, start)
        lt.val_type(val, _value_type)
        start = start or 1
        lt.val_integer(start)
        local res = nil

        for idx = start, #_data do
            if _data[idx] == val then
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
    function list:find_all(func)
        lt.val_func(func)
        local res = {}
        for i = 1, #_data do
            local v = _data[i]
            if func(v) then
                res[#res + 1] = v
            end
        end

        return res
    end


    ------------------------- Finish ----------------------------------------

    local mt =
    {
        -- __call = TODOL??,
        __index = function(t, index)
            return _data[index]
        end,
        __newindex = function(t, index, value)
             _check_val(value)
             rawset(_data, index, value)
        end,
        __tostring = function(t)
            return string.format('%s(%s)[%s]', _name, _class, _value_type)
        end,
    }
    setmetatable(list, mt)

    return list
end

-------------------------------------------------------------------------
return M
