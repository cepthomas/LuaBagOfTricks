-- A typed list class in the lua prototype style with homogenous values.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.

local ut = require("lbot_utils")
local lt = require("lbot_types")
local tx = require("tableex")
local sx = require("stringex")


-- Helper.
local function who_called_me()
    local filepath, linenumber, _ = ut.get_caller_info(4)
    return filepath..'('..linenumber..')'
end



-----------------------------------------------------------------------------
--- Create a typed list.
-- @param init a not-empty table, or a type name: number, string, boolean, table, function.
-- @param name optional name
-- @return a new list
function List(init, name)
    local ll = {} -- our storage
    local value_type = nil

    -- Determine flavor.
    local valid_types = { 'number', 'string', 'boolean', 'table', 'function' }
    local stype = type(init)

    if stype == 'string' and tx.contains(valid_types, init) then
        value_type = init
    elseif stype == 'table' then
        -- Check that the table is correct.
        local num = 0
        -- local val_type = nil

        -- Check for empty - can't determine type.
        if #init == 0 then error('Can\'t create a List from empty table') end

        -- Check if all keys are indexes.
        for k, _ in pairs(init) do
            if type(k) ~= 'number' then error('Indexes must be number') end
            num = num + 1
        end

        -- Check sequential from 1.
        for i = 1, num do
            if init[i] == nil then error('Indexes must be sequential') end
        end

        -- Check value type.
        for i = 1, num do
            if i == 1 then value_type = type(init[i]) -- init
            elseif type(init[i]) ~= value_type then error('Values must be homogenous')
            end
        end

        -- Must be ok then.
        ll = init
        -- ll.value_type = val_type
    else
        error('Invalid value type:'..stype)
    end

    -- Good to go. Do meta stuff, properties.
    setmetatable(ll,
    {
        name = name or 'no-name',
        value_type = value_type,
        __tostring = function(self) return 'List:['..self:name()..'] type:'..self:value_type()..' len:'..tostring(self:count()) end,
        -- __call = function(...) print('__call', ...) end,
    })

    -------------------------------------------------------------------------
    -- Properties
    function ll:name() return getmetatable(ll).name end
    function ll:value_type() return getmetatable(ll).value_type end


    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @return a string
    function ll:dump()
        local res = {}
        table.insert(res, 'List('..ll:value_type()..') ['..ll:name()..']')
        for _, v in ipairs(ll) do
            table.insert(res, '    '..v)
        end
        return sx.strjoin('\n', res)
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
    -- @param v An item/value
    -- @return the list
    function ll:add(v)
        lt.val_type(v, ll.value_type())
        table.insert(ll, v)
        return ll
    end

    -------------------------------------------------------------------------
    --- Extend the list by appending all the items in the given list.
    -- @tparam other List to append
    -- @return the list
    function ll:add_range(other)
        lt.val_table(other, 0)
        for i = 1, #other do table.insert(ll, other[i]) end
        return ll
    end

    -------------------------------------------------------------------------
    --- Insert an item at a given position. i is the index of the element before which to insert.
    -- @int i index of element before which to insert
    -- @param x A data item
    -- @return the list
    function ll:insert(i, x)
        lt.val_integer(i, 1, #ll)
        table.insert(ll, i, x)
        return ll
    end

    -------------------------------------------------------------------------
    --- Remove an element given its index.
    -- @int i the index
    -- @return the list
    function ll:remove_at(i)
        lt.val_integer(i, 1, #ll)
        table.remove(ll, i)
        return ll
    end

    -------------------------------------------------------------------------
    --- Remove the first value from the list.
    -- @param v data value
    -- @return the list
    function ll:remove(v)
        lt.val_not_nil(v)
        for i = 1, #ll do
            if ll[i] == v then table.remove(ll, i) return ll end
        end
        return ll
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
    -- @return the list
    function ll:sort(cmp)
        lt.val_func(cmp)
        if not cmp then cmp = function(a, b) return b < a end end
        table.sort(ll, cmp)
        return ll
    end

    -------------------------------------------------------------------------
    --- Reverse the elements of the list, in place.
    -- @return the list
    function ll:reverse()
        local t = ll
        local n = #t
        for i = 1, n / 2 do
            t[i], t[n] = t[n], t[i]
            n = n - 1
        end
        return ll
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
        lt.val_type(v, ll.value_type())
        -- lt.val_integer(start)
        local res = nil

        local i = start or 1
        for idx = i, #ll do
            if ll[idx] == v then res = idx end
        end
        return res
    end

    -------------------------------------------------------------------------
    --- Create a list of all elements which match a function.
    -- @param func a boolean function
    -- @param arg optional argument to be passed as second argument of the predicate
    -- @return new filtered list
    function ll:find_all(func, arg)
        lt.val_func(func)
        local ls = {}
        -- local res = filter(ll, func, arg)

        local k
        for i = 1, #ll do
            local v = ll[i]
            if func(v, arg) then
                ls[k] = v
                k = k + 1
            end
        end

        return List(ls)
    end

    -------------------------------------------------------------------------
    --- Call the function on each element of the list.
    -- @param func a function or callable object
    -- @param ... optional values to pass to function
    function ll:foreach(func, ...)
        lt.val_func(func)
        for i = 1, #ll do
            func(ll[i], ...)
        end
    end

    -------------------------------------------------------------------------

    return ll
end
