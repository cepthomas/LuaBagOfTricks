------------------------- dict ----------------------------

-- limit keys and values to one type?


--[[
https://lunarmodules.github.io/Penlight/classes/pl.Map.html
Dependencies: pl.utils, pl.class, pl.tablex, pl.pretty


Fields
pl.Map.keys     list of keys.
pl.Map.values   list of values.
Methods
pl.Map:iter ()  return an iterator over all key-value pairs.
pl.Map:items ()     return a List of all key-value pairs, sorted by the keys.
pl.Map:setdefault (key, default)    set a value in the map if it doesn't exist yet.
pl.Map:len ()   size of map.
pl.Map:set (key, val)   put a value into the map.
pl.Map:get (key)    get a value from the map.
pl.Map:getvalues (keys)     get a list of values indexed by a list of keys.
pl.Map:update (table)   update the map using key/value pairs from another table.
Metamethods
pl.Map:__eq (m)     equality between maps.
pl.Map:__tostring ()    string representation of a map.

]]


-- Map = require 'pl.Map'
-- m = Map{one=1,two=2}
-- m:update {three=3,four=4,two=20}
-- = m == M{one=1,two=20,three=3,four=4}
-- true

-- local colors = { ['Build: ']='green', ['! ']='red', ['): error ']='red', ['): warning ']='yellow' }
-- mydict = dict(colors)

