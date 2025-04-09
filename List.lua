--[[
Borrowed simple subset from penlight. Names are modelled after C# instead of python.

TODOF maybe some of these:
int LastIndexOf(T item, int index)
void InsertRange(int index, IEnumerable<T> collection)
void RemoveRange(int index, int count)
map (fun, ...)     Apply a function to all elements.
transform (fun, ...)   Apply a function to all elements, in-place.
reduce (fun)   'reduce' a list using a binary function.
partition (fun, ...)   Partition a list using a classifier function.
]]


ut = require 'lbot_utils'
tx = require 'tableex'



-- Meta stuff. TODOL play with. https://www.lua.org/manual/5.4/manual.html#2.4
mt = {
        __tostring = function(self) return 'List:['..self.name..'] type:'..self.value_type..' len:'..tostring(self:count()) end,
        -- __index = function(self, ...) end,
        -- __newindex = function(self, ...) end,
        -- __call = function(self, ...) end
     }

-----------------------------------------------------------------------------
--- Create a typed list.
-- @param init a not-empty table, or a type name: "number", "string", "boolean", "table", "function".
-- @param name optional name
-- @return a new list
function List(init, name)
    local _o = {} -- our storage

    -- Determine flavor.
    local valid_types = { "number", "string", "boolean", "table", "function" }
    local stype = type(init)

    if stype == 'string' and _valid_types:contains(stype) then
        _o.value_type = stype
    elseif stype == 'table' then
        -- Check for empty - can't determine type.
        if #init == 0 then error('Can\'t create a List from empty table') end

        -- Check for pure array type.
        local ok, val_type = ut.is_array(init)
        if not ok then error('Not a List array') end
        if val_type == nil then error('Not homogenous values') end
        _o = init
        _o.value_type = type(_o[1])
    else
        error('Invalid value type: '..stype)
    end

    -- Good to go.
    _o.name = name or 'no-name'
    setmetatable(_o, mt)


    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @return a list of values
    function _o:dump()
        local res = {}
        for _, v in ipairs(tbl) do
            table.insert(res, v)
        end
        return res
    end

    -------------------------------------------------------------------------
    --- How many.
    -- @return the count
    function _o:count()
        return #_o
    end

    -------------------------------------------------------------------------
    --- Copy from an existing list.
    -- @param i index of start element, or nil means all aka clone
    -- @param count how many, or nil means end
    -- @return the new List
    function _o:get_range(i, count)
        local ls = {}

        local first
        local last
        if i == nil then
            first = 1
            last = #_o
        elseif count == nil then
            first = i
            last = #_o
        else
            first = i
            last = first + count - 1
        end

        for ind = first, last do
            table.insert(ls, _o[ind])
        end

        return List(ls)
    end

    -------------------------------------------------------------------------
    --- Add an item to the end of the list.
    -- @param v An item/value
    -- @return the list
    function _o:add(v)
        ut.val_type(v, _o.value_type)
        table.insert(_o, v)
        return _o
    end

    -------------------------------------------------------------------------
    --- Extend the list by appending all the items in the given list.
    -- @tparam other List to append
    -- @return the list
    function _o:add_range(other)
        ut.val_table(other, 0)
        for i = 1, #other do table.insert(_o, other[i]) end
        return _o
    end

    -------------------------------------------------------------------------
    --- Insert an item at a given position. i is the index of the element before which to insert.
    -- @int i index of element before which to insert
    -- @param x A data item
    -- @return the list
    function _o:insert(i, x)
        ut.val_integer(i, 1, #_o)
        table.insert(_o, i, x)
        return _o
    end

    -------------------------------------------------------------------------
    --- Remove an element given its index.
    -- @int i the index
    -- @return the list
    function _o:remove_at(i)
        ut.val_integer(i, 1, #_o)
        table.remove(_o, i)
        return _o
    end

    -------------------------------------------------------------------------
    --- Remove the first value from the list.
    -- @param v data value
    -- @return the list
    function _o:remove(v)
        ut.val_not_nil(v)
        for i = 1, #_o do
            if _o[i] == v then table.remove(_o, i) return _o end
        end
        return _o
     end

    -------------------------------------------------------------------------
    --- Return the index in the list of the first item whose value is given.
    -- @paramtion _o:index
    -- @param v data value
    -- @int i where to start search, nil means beginning
    -- @return the index, or nil if not found
    function _o:index_of(v, i)
        ut.val_not_nil(v)
        i = i or 1
        if i < 0 then i = #_o + i + 1 end
        for ind = i, #_o do
            if _o[ind] == v then return ind end
        end
        return nil
    end

    -------------------------------------------------------------------------
    --- Does list contain value.
    -- @param v data value
    -- @return bool
    function _o:contains(v)
        ut.val_not_nil(v)
        local res = _o:find(v)
        return res ~= nil
        -- return _o:find(v) ~= nil or false
        -- return _o:find(v) ~= nil  --and true or false
    end

    -------------------------------------------------------------------------
    --- Sort the items of the list in place.
    -- @param cmp comparison function, or simple ascending if nil
    -- @return the list
    function _o:sort(cmp)
        ut.val_func(cmp)
        if not cmp then cmp = function(a, b) return b < a end end
        table.sort(_o, cmp)
        return _o
    end

    -------------------------------------------------------------------------
    --- Reverse the elements of the list, in place.
    -- @return the list
    function _o:reverse()
        local t = _o
        local n = #t
        for i = 1, n / 2 do
            t[i], t[n] = t[n], t[i]
            n = n - 1
        end
        return _o
    end

    -------------------------------------------------------------------------
    --- Empty the list.
    -- @return the list
    function _o:clear()
        for i = 1, #_o do table.remove(_o) end
        return _o
    end

    -------------------------------------------------------------------------
    --- Return the index of a value in a list.
    -- @param v the value
    -- @param start where to start
    -- @return index of value, or nil if not found
    function _o:find(v, start)
        ut.val_type(v, _o.value_type)
        -- ut.val_integer(start)
        local res = nil

        local i = start or 1
        for idx = i, #_o do
            if _o[idx] == v then res = idx end
        end
        return res
    end

    -------------------------------------------------------------------------
    --- Create a list of all elements which match a function.
    -- @param func a boolean function
    -- @param arg optional argument to be passed as second argument of the predicate
    -- @return new filtered list
    function _o:find_all(func, arg)
        ut.val_func(func)
        local ls = {}
        -- local res = filter(_o, func, arg)

        for i = 1, #_o do
            local v = _o[i]
            if func(v, arg) then
                res[k] = v
                k = k + 1
            end
        end

        return List(res)
    end

    -------------------------------------------------------------------------
    --- Call the function on each element of the list.
    -- @param func a function or callable object
    -- @param ... optional values to pass to function
    function _o:foreach(func, ...)
        ut.val_func(func)
        for i = 1, #_o do
            func(_o[i], ...)
        end
    end

    -------------------------------------------------------------------------
    return _o
end
