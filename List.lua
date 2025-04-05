------------------------- list ----------------------------


local iter
local tinsert, tremove, concat, tsort = table.insert, table.remove, table.concat, table.sort
local setmetatable, getmetatable, type, tostring, string = setmetatable, getmetatable, type, tostring, string

-- local List = {}
ut = require 'lbot_utils'
tx = require 'tableex'


function List(init)
    local vtype = nil -- "nil", "number", "string", "boolean", "table", "function", "thread", "userdata". 
    local o =  nil --{} -- this is our storage
    local valid_dtypes = {"number", "string", "boolean", "table", "function"}

    -- Test init for
    itype = type(init)
    if itype == 'table' then o = init
    elseif valid_dtypes:contains(itype) then vtype = itype; o = { init }
    else error('TODOL')
    end

    -- TODOL test homogenous value types

    -- function o:getName(i)
    --     return o[i]
    -- end

    -- function o:setName(n)
    --     name = n
    -- end

    function o:len()
        return #o
    end


    --- Make a copy of an existing list.
    -- The difference from a plain 'copy constructor' is that this returns the actual List subtype.
    function o:clone()
        local ls = makelist({}, self)
        ls:extend(self)
        return ls
    end

    --- Add an item to the end of the list.
    -- @param v An item/value
    -- @return the list
    function o:append(v)
        tinsert(o, v)
        return self
    end

    o.push = tinsert

    --- Extend the list by appending all the items in the given list.
    -- equivalent to 'a[len(a):] = other'.
    -- @tparam List other Another List
    -- @return the list
    function o:extend(other)
        ut.assert_arg(1, other, 'table')
        for i = 1, #other do tinsert(self, other[i]) end
        return self
    end

    --- Insert an item at a given position. i is the index of the element before which to insert.
    -- @int i index of element before which to insert
    -- @param x A data item
    -- @return the list
    function o:insert(i, x)
        ut.assert_arg(1, i, 'number')
        tinsert(self, i, x)
        return self
    end

    --- Insert an item at the begining of the list.
    -- @param x a data item
    -- @return the list
    function o:put(x)
        return self:insert(1, x)
    end

    --- Remove an element given its index.
    -- (equivalent of Python's del s[i])
    -- @int i the index
    -- @return the list
    function o:remove (i)
        ut.assert_arg(1, i, 'number')
        tremove(self, i)
        return self
    end

    --- Remove the first item from the list whose value is given.
    -- (This is called 'remove' in Python; renamed to avoid confusion with table.remove)
    -- Return nil if there is no such item.
    -- @param v A data value
    -- @return the list
    function o:remove_value(v)
        for i = 1, #self do
            if self[i] == v then tremove(self, i) return self end
        end
        return self
     end

    --- Remove the item at the given position in the list, and return it.
    -- If no index is specified, a:pop() returns the last item in the list.
    -- The item is also removed from the list.
    -- @int[opt] i An index
    -- @return the item
    function o:pop(i)
        if not i then i = #self end
        ut.assert_arg(1, i, 'number')
        return tremove(self,i)
    end

    o.get = o.pop

    --- Return the index in the list of the first item whose value is given.
    -- Return nil if there is no such item.
    -- @function o:index
    -- @param x A data value
    -- @int[opt=1] idx where to start search
    -- @return the index, or nil if not found.

    local tfind = tx.find
    o.index = tfind

    --- Does this list contain the value?
    -- @param v A data value
    -- @return true or false
    function o:contains(v)
        return tfind(self, v) and true or false
    end

    --- Return the number of times value appears in the list.
    -- @param v A data value
    -- @return number of times v appears
    function o:count(v)
        local cnt=0
        for i = 1, #self do
            if self[i] == v then cnt = cnt + 1 end
        end
        return cnt
    end

    --- Sort the items of the list, in place.
    -- @func[opt='<'] cmp an optional comparison function
    -- @return the list
    function o:sort(cmp)
        if cmp then cmp = function_arg(1, cmp) end
        tsort(self, cmp)
        return self
    end

    --- Reverse the elements of the list, in place.
    -- @return the list
    function o:reverse()
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
    function o:clear()
        for i = 1,#self do tremove(self) end
        return self
    end

    -------------- Extended operations ------------------

    --- How our list should be rendered as a string.
    -- @within metamethods
    function o:__tostring()
        return 'List len:'..tostring(o:len())
    end

    --- Call the function on each element of the list.
    -- @func fun a function or callable object
    -- @param ... optional values to pass to function
    function o:foreach(fun, ...)
        fun = function_arg(1, fun)
        for i = 1, #self do
            fun(self[i], ...)
        end
    end

    -- we want the result to be _covariant_, i.e. t must have type of obj if possible
    local function makelist(t, obj)
        local klass = List
        if obj then
            klass = getmetatable(obj)
        end
        return setmetatable(t, klass)
    end

    --- Create a list of all elements which match a function.
    -- @func fun a boolean function
    -- @param[opt] arg optional argument to be passed as second argument of the predicate
    -- @return a new filtered list.
    function o:filter(fun, arg)
        return makelist(filter(self, fun, arg), self)
    end

    --- return an iterator over all values.
    function o:iter()
        return ut.iter(self)
    end

    -- --- Create an iterator over a seqence. This captures the Python concept of 'sequence'.
    -- -- For tables, iterates over all values with integer indices.
    -- -- @param seq a sequence; a string (over characters), a table, a file object (over lines) or an iterator function
    -- -- @usage for x in iterate {1,10,22,55} do io.write(x,',') end ==> 1,10,22,55
    -- -- @usage for ch in iterate 'help' do do io.write(ch,' ') end ==> h e l p
    -- local function iterate(seq)
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
    -- ???
    iter = iterate

    return o
end




--[[
https://lunarmodules.github.io/Penlight/classes/pl.List.html
Dependencies: pl.utils, pl.tablex, pl.class

methods maybe
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

metamethods
List:__concat (L)   Concatenation operator.
List:__eq (L)   Equality operator ==.
List:__tostring ()  How our list should be rendered as a string.
]]
