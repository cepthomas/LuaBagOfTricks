-- A typed list class in the lua prototype style with homogenous values.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.

local ut = require("lbot_utils")
local lt = require("lbot_types")
local sx = require("stringex")


-----------------------------------------------------------------------------
--- Create a typed list.
-- @param t array-like table to init the List, or nil for deferred
-- @param name optional name
-- @return a new List object
function List(t, name)
    if t ~= nil and type(t) ~= 'table' then error('Invalid initializer: '..type(t)) end
    local ll = {} -- our storage

    ------------------------ Properties -------------------------------------

    function ll:name() return getmetatable(ll).name end
    function ll:class() return getmetatable(ll).class end
    function ll:value_type() return getmetatable(ll).value_type end

    ------------------------- Private ---------------------------------------

    -------------------------------------------------------------------------
    --- Check type of value. Also does lazy init. Raises error.
    -- @param v the value to check
    local function check_val(v)
        local vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

        if #ll == 0 then
            -- New object, check valid type
            local valid_types = { 'number', 'integer', 'string', 'boolean', 'table', 'function' }
            for _, vt in ipairs(valid_types) do
                if vtype == vt then
                    local mt = getmetatable(ll)
                    mt.value_type = vtype
                    setmetatable(ll, mt)
                end
            end

            if ll:value_type() == nil then
                error('Invalid value type:'..vtype)
            end
        else
            -- It's an add, check type.
            if vtype ~= ll:value_type() then error('Values not homogenous') end
        end
    end

    ------------------------- Public ----------------------------------------

    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @return a string
    function ll:dump()
        local res = {}
        table.insert(res, tostring(ll))
        for _, v in ipairs(ll) do
            table.insert(res, tostring(v))
        end
        return sx.strjoin(',', res)
    end

    -------------------------------------------------------------------------
    --- How many.
    -- @return the count
    function ll:count()
        return #ll
    end

    -------------------------------------------------------------------------
    --- Copy from an existing list.
    -- @param i index of start element, or nil means all aka clone
    -- @param count how many, or nil means end
    -- @return the new List
    function ll:get_range(i, count)
        local ls = {}

        local first
        local last
        if i == nil then
            first = 1
            last = #ll
        elseif count == nil then
            first = i
            last = #ll
        else
            first = i
            last = first + count - 1
        end

        for ind = first, last do
            table.insert(ls, ll[ind])
        end

        return List(ls)
    end

    -------------------------------------------------------------------------
    --- Add an item to the end of the list.
    -- @param v the item/value
    function ll:add(v)
        check_val(v)
        table.insert(ll, v)
    end

    -------------------------------------------------------------------------
    --- Extend the list by appending all the items in the given list.
    -- @param other List to append
    function ll:add_range(other)
        lt.val_table(other, 1)
        for i = 1, #other do
            check_val(other[i])
            table.insert(ll, other[i])
        end
    end

    -------------------------------------------------------------------------
    --- Insert an item at a given position. i is the index of the element before which to insert.
    -- @int i index of element before which to insert
    -- @param v the item/value
    function ll:insert(i, v)
        lt.val_integer(i, 1, #ll)
        check_val(v)
        table.insert(ll, i, v)
    end

    -------------------------------------------------------------------------
    --- Remove an element given its index.
    -- @int i the index
    function ll:remove_at(i)
        lt.val_integer(i, 1, #ll)
        table.remove(ll, i)
    end

    -------------------------------------------------------------------------
    --- Remove the first value from the list.
    -- @param v data value
    function ll:remove(v)
        lt.val_not_nil(v)
        for i = 1, #ll do
            if ll[i] == v then table.remove(ll, i) return ll end
        end
     end

    -------------------------------------------------------------------------
    --- Return the index in the list of the first item whose value is given.
    -- @paramtion ll:index
    -- @param v data value
    -- @int i where to start search, nil means beginning
    -- @return the index, or nil if not found
    function ll:index_of(v, i)
        lt.val_not_nil(v)
        i = i or 1
        if i < 0 then i = #ll + i + 1 end
        for ind = i, #ll do
            if ll[ind] == v then return ind end
        end
        return nil
    end

    -------------------------------------------------------------------------
    --- Does list contain value.
    -- @param v data value
    -- @return bool
    function ll:contains(v)
        lt.val_not_nil(v)
        local res = ll:find(v)
        return res ~= nil
        -- return ll:find(v) ~= nil or false
        -- return ll:find(v) ~= nil  --and true or false
    end

    -------------------------------------------------------------------------
    --- Sort the items of the list in place.
    -- @param cmp comparison function, or simple ascending if nil
    function ll:sort(cmp)
        lt.val_func(cmp)
        if not cmp then cmp = function(a, b) return b < a end end
        table.sort(ll, cmp)
    end

    -------------------------------------------------------------------------
    --- Reverse the elements of the list, in place.
    function ll:reverse()
        local tr = ll
        local n = #tr
        for i = 1, n / 2 do
            tr[i], tr[n] = tr[n], tr[i]
            n = n - 1
        end
    end

    -------------------------------------------------------------------------
    --- Empty the list.
    -- @return the list
    function ll:clear()
        for _ = 1, #ll do table.remove(ll) end
        return ll
    end

    -------------------------------------------------------------------------
    --- Return the index of a value in a list.
    -- @param v the value
    -- @param start where to start
    -- @return index of value, or nil if not found
    function ll:find(v, start)
        lt.val_type(v, ll:value_type())
        start = start or 1
        lt.val_integer(start)
        local res = nil

        for idx = start, #ll do
            if ll[idx] == v then
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
    function ll:find_all(func)
        lt.val_func(func)
        local ls = {}
        local k = 1
        for i = 1, #ll do
            local v = ll[i]
            if func(v) then
                ls[k] = v
                k = k + 1
            end
        end

        return List(ls)
    end

    ------------------------- Initialization --------------------------------

    -------------------------------------------------------------------------
    -- Object has been created. Finish up data initialization.
    setmetatable(ll,
    {
        name = name or 'no_name',
        class = 'List',
        __tostring = function(self) return string.format('%s:(%s)[%d] "%s"',
                        self:class(), self:value_type(), self:count(), self:name()) end,
        -- __call = function(...) print('__call', ...) end,
    })

    if t ~= nil then
        -- Check that the table is array-like.
        -- Are all keys indexes.
        local num = 0
        for k, _ in pairs(t) do
            if not lt.is_integer(k) then error('Indexes must be integer') end
            num = num + 1
        end
        -- Are sequential from 1.
        for i = 1, num do
            if t[i] == nil then error('Indexes must be sequential') end
        end

        -- Copy the data. This tests for homogenity.
        for _, v in ipairs(t) do ll:add(v) end
    end

    return ll
end
