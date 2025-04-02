------------------------- list ----------------------------
--[[
https://lunarmodules.github.io/Penlight/classes/pl.List.html
Dependencies: pl.utils, pl.tablex, pl.class

methods
List.new ([t])  Create a new list.
List:clone ()   Make a copy of an existing list.
List:append (i)     Add an item to the end of the list.
List:extend (L)     Extend the list by appending all the items in the given list.
List:insert (i, x)  Insert an item at a given position.
List:put (x)    Insert an item at the begining of the list.
List:remove (i)     Remove an element given its index.
List:remove_value (x)   Remove the first item from the list whose value is given.
List:pop ([i])  Remove the item at the given position in the list, and return it.
List:index (x[, idx=1])     Return the index in the list of the first item whose value is given.
List:contains (x)   Does this list contain the value?
List:count (x)  Return the number of times value appears in the list.
List:sort ([cmp='<'])   Sort the items of the list, in place.
List:sorted ([cmp='<'])     Return a sorted copy of this list.
List:reverse ()     Reverse the elements of the list, in place.
List:minmax ()  Return the minimum and the maximum value of the list.
List:slice (first, last)    Emulate list slicing.
List:clear ()   Empty the list.
List.range (start[, finish[, incr=1] ])  Emulate Python range(x)
List:len ()     list:len() is the same as #list.
List:chop (i1, i2)  Remove a subrange of elements.
List:splice (idx, list)     Insert a sublist into a list equivalent to 's[idx:idx] = list' in Python
List:slice_assign (i1, i2, seq)     General slice assignment s[i1:i2] = seq.
List:join ([delim=''])  Join the elements of a list using a delimiter.
List:concat ([delim=''])    Join a list of strings.
List:foreach (fun, ...)     Call the function on each element of the list.
List:foreachm (name, ...)   Call the named method on each element of the list.
List:filter (fun[, arg])    Create a list of all elements which match a function.
List.split (s[, delim])     Split a string using a delimiter.
List:map (fun, ...)     Apply a function to all elements.
List:transform (fun, ...)   Apply a function to all elements, in-place.
List:map2 (fun, ls, ...)    Apply a function to elements of two lists.
List:mapm (name, ...)   apply a named method to all elements.
List:reduce (fun)   'reduce' a list using a binary function.
List:partition (fun, ...)   Partition a list using a classifier function.
List:iter ()    return an iterator over all values.
List.iterate (seq)  Create an iterator over a seqence.
metamethods
List:__concat (L)   Concatenation operator.
List:__eq (L)   Equality operator ==.
List:__tostring ()  How our list should be rendered as a string.

ls = List {}
ls = List {1,2,3,4}
]]

-- local exp_neb = {'luainterop', 'setup', 'step', 'receive_midi_note', 'receive_midi_controller' }
-- mylist = list exp_neb

require 'class'


List = class(
    function(a, name)
        a.name = name
    end)


local Animal = class(
    function(a, name)
        a.name = name
    end)

function Animal:__tostring()
    return self.name..': '..self:speak()
end

---------- create
Dog = class(Animal)

function Dog:speak()
    return 'bark'
end

---------- inherit
Cat = class(Animal,
    function(c, name, breed)
        Animal.__init(c, name) -- must init base!
        c.breed = breed
    end)

function Cat:speak()
    return 'meow'
end

---------- create
Lion = class(Cat)

function Lion:speak()
    return 'roar'
end


-----------------------------------------------------------------------------
function M.suite_class(pn)
    -- Test all functions in class.lua

    local fido = Dog('Fido')
    local felix = Cat('Felix', 'Tabby')
    local leo = Lion('Leo', 'African')

    pn.UT_EQUAL(tostring(fido), "Fido: bark")
    pn.UT_EQUAL(tostring(felix), "Felix: meow")
    pn.UT_EQUAL(tostring(leo), "Leo: roar")
    pn.UT_TRUE(leo:is_a(Animal))
    pn.UT_FALSE(leo:is_a(Dog))
    pn.UT_TRUE(leo:is_a(Cat))

end
