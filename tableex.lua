------------------------- table ----------------------------

--[[

table builtin: .concat, .insert, .move, .pack, .remove, .sort, .unpack

https://lunarmodules.github.io/Penlight/libraries/pl.tablex.html
Dependencies: pl.utils, pl.types

Functions
size (t)    total number of elements in this table.
index_by (tbl, idx)     return a list of all values in a table indexed by another list.
transform (fun, t, ...)     apply a function to all values of a table, in-place.
range (start, finish[, step=1])     generate a table of all numbers in a range.
reduce (fun, t, memo)   'reduce' a list using a binary function.
index_map (t)   create an index map from a list-like table.
makeset (t)     create a set from a list-like table.
union (t1, t2)  the union of two map-like tables.
intersection (t1, t2)   the intersection of two map-like tables.
count_map (t, cmp)  A table where the key/values are the values and value counts of the table.
set (t, val[, i1=1[, i2=#t] ])   set an array range to a value.
new (n, val)    create a new array of specified size with initial value.
clear (t, istart)   clear out the contents of a table.
removevalues (t, i1, i2)    remove a range of values from a table.
readonly (t)    modifies a table to be read only.

Copying
update (t1, t2)     copy a table into another, in-place.
copy (t)    make a shallow copy of a table
deepcopy (t)    make a deep copy of a table, recursively copying all the keys and fields.
icopy (dest, src[, idest=1[, isrc=1[, nsrc=#src] ] ])     copy an array into another one, clearing dest after idest+nsrc, if necessary.
move (dest, src[, idest=1[, isrc=1[, nsrc=#src] ] ])  copy an array into another one.
insertvalues (t[, position], values)    insert values into a table.

Comparing
deepcompare (t1, t2[, ignore_mt[, eps] ])    compare two values.
compare (t1, t2, cmp)   compare two arrays using a predicate.
compare_no_order (t1, t2, cmp)  compare two list-like tables using an optional predicate, without regard for element order.

Finding
find (t, val, idx)  return the index of a value in a list.
rfind (t, val, idx)     return the index of a value in a list, searching from the end.
find_if (t, cmp, arg)   return the index (or key) of a value in a table using a comparison function.
search (t, value[, exclude])    find a value in a table by recursive search.

MappingAndFiltering
map (fun, t, ...)   apply a function to all values of a table.
imap (fun, t, ...)  apply a function to all values of a list.
map_named_method (name, t, ...)     apply a named method to values from a table.
map2 (fun, t1, t2, ...)     apply a function to values from two tables.
imap2 (fun, t1, t2, ...)    apply a function to values from two arrays.
mapn (fun, ..., fun)    Apply a function to a number of tables.
pairmap (fun, t, ...)   call the function with the key and value pairs from a table.
filter (t, pred, arg)   filter an array's values using a predicate function

Iterating
foreach (t, fun, ...)   apply a function to all elements of a table.
foreachi (t, fun, ...)  apply a function to all elements of a list-like table in order.
sort (t, f)     return an iterator to a table sorted by its keys
sortv (t, f)    return an iterator to a table sorted by its values

Extraction
keys (t)    return all the keys of a table in arbitrary order.
values (t)  return all the values of the table in arbitrary order
sub (t, first, last)    Extract a range from a table, like 'string.sub'.

Merging
merge (t1, t2, dup)     combine two tables, either as union or intersection.
difference (s1, s2, symm)   a new table which is the difference of two tables.
zip (...)   return a table where each element is a table of the ith values of an arbitrary number of tables.

]]




local sx = require("stringex")

local M = {}

-- For table dumping.
local _dump_level = 0


-----------------------------------------------------------------------------
--- Get all the keys of tbl.
-- @param tbl the table
-- @return list of keys
function M.keys(tbl)
    local res = {}
    for k, _ in pairs(tbl) do
        table.insert(res, k)
    end
    return res
end

-----------------------------------------------------------------------------
--- Get all the values of tbl.
-- @param tbl the table
-- @return list of values
function M.values(tbl)
    local res = {}
    for _, v in pairs(tbl) do
        table.insert(res, v)
    end
    return res
end

-----------------------------------------------------------------------------
--- Lua has no built in way to count number of values in an associative table so this does.
-- @param tbl the table
-- @return number of values
function M.table_count(tbl)
    local num = 0
    for _, _ in pairs(tbl) do
        num = num + 1
    end
    return num
end

-----------------------------------------------------------------------------
--- Tests if the value is in the table.
-- @param tbl the table
-- @param val the value
-- @return corresponding key or nil if not in tbl
function M.contains(tbl, val)
    local num = 0
    for k, v in pairs(tbl) do
        if v == val then return k end
    end
    return nil
end

-----------------------------------------------------------------------------
-- Boilerplate for adding a new kv to a table.
-- @param tbl the table
-- @param key new entry key
-- @param val new entry value
function M.table_add(tbl, key, val)
   if tbl[key] == nil then tbl[key] = {} end
   table.insert(tbl[key], val)
end

-----------------------------------------------------------------------------
-- Shallow copy of tbl.
-- @param tbl the table
-- @return new table
function M.copy(tbl)
    local res = {}
    for k, v in pairs(tbl) do
        res[k] = v
    end
    return res
end

-----------------------------------------------------------------------------
--- Diagnostic.
-- @param tbl What to dump.
-- @param depth How deep to go in recursion. 0 means just this level.
-- @param name Of the tbl.
-- @param indent Nesting.
-- @return list table of strings
function M.dump_table(tbl, depth, name, indent)
    local res = {}
    indent = indent or 0
    name = name or "no_name"

    if type(tbl) == "table" then
        local sindent = string.rep("    ", indent)
        table.insert(res, sindent..name.."(table):")

        -- Do contents.
        indent = indent + 1
        sindent = sindent.."    "
        for k, v in pairs(tbl) do
            if type(v) == "table" and _dump_level < depth then
                _dump_level = _dump_level + 1
                trec = M.dump_table(v, depth, k, indent) -- recursion!
                _dump_level = _dump_level - 1
                for _, v2 in ipairs(trec) do
                    table.insert(res, v2)
                end
            else
                table.insert(res, sindent..k..":"..tostring(v).."("..type(v)..")")
            end
        end
    else
        table.insert(res, "Not a table")
    end

    return res
end

-----------------------------------------------------------------------------
--- Diagnostic. Dump table as formatted strings.
-- @param tbl What to dump.
-- @param depth How deep to go in recursion. 0 means just this level.
-- @param name Of tbl.
-- @return string Formatted/multiline contents
function M.dump_table_string(tbl, depth, name)
    local res = M.dump_table(tbl, depth, name, 0)
    return sx.strjoin('\n', res)
end

-----------------------------------------------------------------------------
--- Diagnostic. 
-- @param lst What to dump.
-- @return string Comma delim line of contents.
function M.dump_list(lst)
    res = {}
    for _, l in ipairs(lst) do
        table.insert(res, l)
    end
    return sx.strjoin(',', res)
end




-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
---------------------------- added ------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

--- return the index of a value in a list.
-- Like string.find, there is an optional index to start searching,
-- which can be negative.
-- @within Finding
-- @array t A list-like table
-- @param val A value
-- @int idx index to start; -1 means last element,etc (default 1)
-- @return index of value or nil if not found
-- @usage find({10,20,30},20) == 2
-- @usage find({'a','b','a','c'},'a',2) == 3
function M.find(t,val,idx)
    -- assert_arg_indexable(1,t)
    idx = idx or 1
    if idx < 0 then idx = #t + idx + 1 end
    for i = idx,#t do
        if t[i] == val then return i end
    end
    return nil
end


-----------------------------------------------------------------------------
-- Return the module.
return M
