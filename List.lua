
-- Borrowed simple subset from penlight. Names are modelled after C# instead of python.


-- local iter
local tinsert, tremove, concat, tsort = table.insert, table.remove, table.concat, table.sort
-- local setmetatable, getmetatable, type, tostring, string = setmetatable, getmetatable, type, tostring, string

-- local List = {}
ut = require 'lbot_utils'
tx = require 'tableex'


--- Create a typed list.
-- @param init a table or type name ("number", "string", "boolean", "table", "function")
-- @param name optional name
-- @return a new list
function List(init, name)
    local _o = {} -- our storage
    -- _o.value_type = nil -- "number", "string", "boolean", "table", "function", "thread", "userdata".

    print('>>>', name, _o.name)

    -- Test init for
    local stype = type(init)

    local valid_types = { "number", "string", "boolean", "table", "function" }


    if stype == 'string' and _valid_types:contains(stype) then
        _o.value_type = stype
    elseif stype == 'table' then
        -- TODOL check:
        --   - more than 0
        --   - only indexed types - keys are int
        --   - values arre all the same
        _o = init
        _o.value_type = type(_o[1])
    else
        error('TODOL')
    end

    _o.name = name or 'no-name'

    local m = getmetatable(_o)
    add __tostring  setmetatable

    --- How many.
    -- @return the count
    function _o:count()
        print('>>>', _o.name, _o.value_type)
        return #_o
    end

    --- Copy from an existing list.
    -- @param i index of start element - nil means all aka clone
    -- @param count how many - nil means end
    -- @return the new List
    function _o:get_range(i, count)
        local ls = {} -- was makelist({}, self)

        local first
        local last
        if i == nil then
            first = 0
            last = #_o
        elseif count == nil then
            first = i
            last = #_o
        else
            first = i
            last = first + count
        end

        for ind = first, last do
            tinsert(ls, _o[ind])
        end

        return List(ls)
    end

    --- Add an item to the end of the list.
    -- @param v An item/value
    -- @return the list
    function _o:add(v)
        tinsert(_o, v)
        return self
    end

    -- _o.push = tinsert

    --- Extend the list by appending all the items in the given list.
    -- equivalent to 'a[len(a):] = other'.
    -- @tparam List other Another List
    -- @return the list
    function _o:add_range(other)
        ut.assert_arg(1, other, 'table')
        for i = 1, #other do tinsert(self, other[i]) end
        return self
    end

    --- Insert an item at a given position. i is the index of the element before which to insert.
    -- @int i index of element before which to insert
    -- @param x A data item
    -- @return the list
    function _o:insert(i, x)
        ut.assert_arg(1, i, 'number')
        tinsert(self, i, x)
        return self
    end

    -- --- Insert an item at the begining of the list.
    -- -- @param x a data item
    -- -- @return the list
    -- function _o:put(x) no
    --     return self:insert(1, x)
    -- end

    --- Remove an element given its index.
    -- (equivalent of Python's del s[i])
    -- @int i the index
    -- @return the list
    function _o:remove_at (i)
        ut.assert_arg(1, i, 'number')
        tremove(self, i)
        return self
    end

    --- Remove the first item from the list whose value is given.
    -- (This is called 'remove' in Python; renamed to avoid confusion with table.remove)
    -- Return nil if there is no such item.
    -- @param v A data value
    -- @return the list
    function _o:remove(v)
        for i = 1, #self do
            if self[i] == v then tremove(self, i) return self end
        end
        return self
     end

    -- --- Remove the item at the given position in the list, and return it.
    -- -- If no index is specified, a:pop() returns the last item in the list.
    -- -- The item is also removed from the list.
    -- -- @int[opt] i An index
    -- -- @return the item
    -- function _o:pop(i)
    --     if not i then i = #self end
    --     ut.assert_arg(1, i, 'number')
    --     return tremove(self,i)
    -- end

    -- _o.get = _o.pop

    --- Return the index in the list of the first item whose value is given.
    -- @paramtion _o:index
    -- @param v A data value
    -- @int[opt=1] i where to start search
    -- @return the index, or nil if not found.
    function _o:index_of(v, i)
        i = i or 1
        if i < 0 then i = #t + i + 1 end
        for ind = i, #t do
            if t[ind] == val then return ind end
        end
        return nil
    end


    --- Does this list contain the value?
    -- @param v A data value
    -- @return true or false
    function _o:contains(v)
        return tfind(self, v) and true or false
    end

    -- --- Return the number of times value appears in the list.
    -- -- @param v A data value
    -- -- @return number of times v appears
    -- function _o:count(v)
    --     local cnt=0
    --     for i = 1, #self do
    --         if self[i] == v then cnt = cnt + 1 end
    --     end
    --     return cnt
    -- end

    --- Sort the items of the list, in place.
    -- @param[opt='<'] cmp an optional comparison function
    -- @return the list
    function _o:sort(cmp)
        if cmp then cmp = function_arg(1, cmp) end
        tsort(self, cmp)
        return self
    end

    --- Reverse the elements of the list, in place.
    -- @return the list
    function _o:reverse()
        local t = self
        local n = #t
        for i = 1, n/2 do
            t[i], t[n] = t[n], t[i]
            n = n - 1
        end
        return self
    end

    --- Empty the list.
    -- @return the list
    function _o:clear()
        for i = 1,#self do tremove(self) end
        return self
    end

    -------------- Extended operations ------------------

    --- Create a list of all elements which match a function.
    -- @param func a boolean function
    -- @param[opt] arg optional argument to be passed as second argument of the predicate
    -- @return a new filtered list.
    function _o:find_all(func, arg) -- TODOL

        local ls = {}

        local res = filter(self, func, arg)

        for i = 1, #_o do
            local v = _o[i]
            if func(v, arg) then
                res[k] = v
                k = k + 1
            end
        end

        -- function tablex.filter (t, pred, arg)
        --     assert_arg_indexable(1, t)
        --     pred = function_arg(2, pred) ok!
        --     local res,k = {},1
        --     for i = 1, #t do
        --         local v = t[i]
        --         if pred(v, arg) then
        --             res[k] = v
        --             k = k + 1
        --         end
        --     end
        --     return setmeta(res, t, 'List')

        return List(res)
    end

    --- Call the function on each element of the list.
    -- @param func a function or callable object
    -- @param ... optional values to pass to function
    function _o:foreach(func, ...)
        func = function_arg(1, func)
        for i = 1, #self do
            func(self[i], ...)
        end
    end

    --- return a list of string contents.
    function _o:dump()
        local res = {}
        for _, v in ipairs(tbl) do
            table.insert(res, v)
        end
        return res
    end

    --- How our list should be rendered as a string.
    -- @within metamethods
    function _o:__tostring()
        return 'List:'.._o.name..' type:'.._o.value_type..' len:'..tostring(_o:count())
    end

    -------------- Internal operations ------------------

    -- -- we want the result to be _covariant_, i.e. t must have type of obj if possible
    -- local function makelist(t, obj)
    --     local klass = List
    --     if obj then
    --         klass = getmetatable(obj)
    --     end
    --     return setmetatable(t, klass)
    -- end

    -- --- return an iterator over all values.
    -- function _o:iter()-- TODOL local?
    --     return ut.iter(self)
    -- end
    -- iter = iterate

-- --- TODOL?? Create an iterator over a seqence. This captures the Python concept of 'sequence'.
-- -- For tables, iterates over all values with integer indices.
-- -- @param seq a sequence; a string (over characters), a table, a file object (over lines) or an iterator function
-- -- @usage for x in iterate {1,10,22,55} do io.write(x,',') end ==> 1,10,22,55
-- -- @usage for ch in iterate 'help' do do io.write(ch,' ') end ==> h e l p
-- function iterate(seq)
--     if type(seq) == 'string' then
--         local idx = 0
--         local n = #seq
--         local sub = string.sub
--         return function ()
--             idx = idx + 1
--             if idx > n then return nil
--             else
--                 return sub(seq, idx, idx)
--             end
--         end
--     elseif type(seq) == 'table' then
--         local idx = 0
--         local n = #seq
--         return function()
--             idx = idx + 1
--             if idx > n then return nil
--             else
--                 return seq[idx]
--             end
--         end
--     elseif type(seq) == 'function' then
--         return seq
--     elseif type(seq) == 'userdata' and io.type(seq) == 'file' then
--         return seq:lines()
--     end
-- end



    return _o
end




--[[
TODOL maybe some of these:
int LastIndexOf(T item, int index)
void InsertRange(int index, IEnumerable<T> collection)
void RemoveRange(int index, int count)
void Sort(IComparer<T>? comparer)

https://lunarmodules.github.io/Penlight/classes/pl.List.html
Dependencies: pl.utils, pl.tablex, pl.class
List.new ([t])  Create a new list.
List:clone ()   Make a copy of an existing list.
List:minmax ()  Return the minimum and the maximum value of the list.
List:sorted ([cmp='<'])     Return a sorted copy of this list.
List:slice (first, last)    Emulate list slicing.
List:clear ()   Empty the list.
List.range (start[, finish[, incr=1] ])  Emulate Python range(x)
List:chop (i1, i2)  Remove a subrange of elements.
List:splice (idx, list)     Insert a sublist into a list equivalent to 's[idx:idx] = list' in Python
List:slice_assign (i1, i2, seq)     General slice assignment s[i1:i2] = seq.
List:join ([delim=''])  Join the elements of a list using a delimiter.
List:concat ([delim=''])    Join a list of strings.
List.split (s[, delim])     Split a string using a delimiter.
List:foreachm (name, ...)   Call the named method on each element of the list.
List:map (fun, ...)     Apply a function to all elements.
List:transform (fun, ...)   Apply a function to all elements, in-place.
List:map2 (fun, ls, ...)    Apply a function to elements of two lists.
List:mapm (name, ...)   apply a named method to all elements.
List:reduce (fun)   'reduce' a list using a binary function.
List:partition (fun, ...)   Partition a list using a classifier function.
List:__concat (L)   Concatenation operator.
List:__eq (L)   Equality operator ==.
List:__tostring ()  How our list should be rendered as a string.
]]
