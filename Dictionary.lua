-- TODOL A typed dictionary class in the lua prototype style with homogenous values.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modedded after C# instead of python.

local ut = require("lbot_utils")
local lt = require("lbot_types")
local tx = require("tableex")


-- Meta stuff.
local mt =
{
    __tostring = function(self) return 'Dictionary:['..self.name..'] type:'..self.value_type..' len:'..tostring(self:count()) end,
    __call = function(...) print('__call', ...) end,
 }


-- pl.Map.keys     list of keys. => keys()
-- pl.Map.values   list of values. => values()
-- pl.Map:len()   size of map. => count()
-- pl.Map:set(key, val)   put a value into the map. combine: pl.Map:setdefault(key, default)    set a value in the map if it doesn't exist yet.
-- pl.Map:get(key)    get a value from the map.
-- pl.Map:update(table)   update the map using key/value pairs from another table. => append/add_range?


-----------------------------------------------------------------------------
--- Create a typed list.
-- @param tbl an initial table.
-- @param name optional name
-- @return a new list
function Dictionary(init, name)
    lt.val_table(tbl, 0)

    local dd = {} -- our storage

    -- Determine flavor.
    local valid_key_types = { 'number', 'string' }
    local valid_val_types = { 'number', 'string', 'boolean', 'table', 'function' }
    local stype = type(init)

    if stype == 'string' and tx.contains(valid_types, init) then
        dd.value_type = init
    elseif stype == 'table' then
        -- Check that the table is correct.
        local num = 0
        local val_type = nil

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
            if i == 1 then val_type = type(init[i]) -- init
            elseif type(init[i]) ~= val_type then error('Values must be homogenous')
            end
        end

        -- Must be ok then.
        dd = init
        dd.value_type = val_type
    else
        error('Invalid value type:'..stype)
    end

    -- Good to go.
    dd.name = name or 'no-name'
    setmetatable(dd, mt)

    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @return a list of values
    function dd:dump()
        local res = {}
        for _, v in ipairs(dd) do
            table.insert(res, v)
        end
        return res
    end

    -------------------------------------------------------------------------
    --- How many.
    -- @return the count
    function dd:count()
        return #dd
    end

    -------------------------------------------------------------------------
    --- Add an item to the end of the list.
    -- @param v An item/value
    -- @return the list
    function dd:add(v)
        lt.val_type(v, dd.value_type)
        table.insert(dd, v)
        return dd
    end

    -------------------------------------------------------------------------
    --- Extend the list by appending all the items in the given list.
    -- @tparam other List to append
    -- @return the list
    function dd:add_range(other)
        lt.val_table(other, 0)
        for i = 1, #other do table.insert(dd, other[i]) end
        return dd
    end

    -------------------------------------------------------------------------
    --- Remove the first value from the list.
    -- @param v data value
    -- @return the list
    function dd:remove(v)
        lt.val_not_nil(v)
        for i = 1, #dd do
            if dd[i] == v then table.remove(dd, i) return dd end
        end
        return dd
     end

    -------------------------------------------------------------------------
    --- Empty the list.
    -- @return the list
    function dd:clear()
        for _ = 1, #dd do table.remove(dd) end
        return dd
    end

    -------------------------------------------------------------------------
    --- Call the function on each element of the list.
    -- @param func a function or callable object
    -- @param ... optional values to pass to function
    function dd:foreach(func, ...)
        lt.val_func(func)
        for i = 1, #dd do
            func(dd[i], ...)
        end
    end

    -------------------------------------------------------------------------
    return dd
end
