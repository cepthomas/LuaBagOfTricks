-- Enhancements to builtin table. Some OOP flavors added.


local ut = require("lbot_utils")
local lt = require("lbot_types")
-- local sx = require("stringex")
-- local ls = require("List")


-- TODOL Add things like these?
--   find_all(func, arg)
--   foreach(func, ...)
-- TODOL: Typed version - see check_val()
-- TODOL: Get a value from the map,  opt for default? __index?
-- TODOL: Add or replace an entry.  __newindex?


--[[ ?? TODOL Create classes like this:
local myclass = {}
-- class table
local MyClass = {}
function MyClass:some_method()
   -- code
end
function MyClass:another_one()
   self:some_method()
   -- more code
end
function myclass.new()
   local self = {}
   setmetatable(self, { __index = MyClass })
   return self
end
return myclass
]]

-- local function makelist(t)
--     return setmetatable(t, require('pl.List'))
-- end


-----------------------------------------------------------------------------
--- Create a fancier table.
-- @param t map-like table to init the Tableex, or nil for deferred
-- @param name optional name
-- @return a new Tableex object
function Tableex(t, name)
    local dd = t or {} -- our storage
    lt.val_table(dd, 0)
    local key_type = nil -- default
    local value_type = nil -- default

    ------------------------ Properties -------------------------------------

    function dd:name() return getmetatable(dd).name end
    function dd:class() return getmetatable(dd).class end
    function dd:key_type() return getmetatable(dd).key_type end
    function dd:value_type() return getmetatable(dd).value_type end


    ------------------------- Private ---------------------------------------

    -------------------------------------------------------------------------
    --- Check type of key and value. Also does lazy init. Raises error.
    -- @param v the value to check
    local function check_val(k, v)
        local ktype = ut.ternary(lt.is_integer(k), 'integer', type(k))
        local vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

        if dd:count() == 0 then -- TODOL cache size?
            -- new object, check types
            local valid_key_types = { 'number', 'string' }
            local valid_val_types = { 'number', 'string', 'boolean', 'table', 'function' }

            if dd:contains(valid_key_types, ktype) then
                local mt = getmetatable(dd)
                mt.key_type = ktype
                setmetatable(dd, mt)
            else
                error('Invalid key type:'..ktype)
            end

            if dd:contains(valid_val_types, vtype) then
                local mt = getmetatable(dd)
                mt.value_type = vtype
                setmetatable(dd, mt)
            else
                error('Invalid value type:'..vtype)
            end

        else
            if ktype ~= dd:key_type() then error('Keys not homogenous') end
            if vtype ~= dd:value_type() then error('Values not homogenous') end
        end
    end

    ------------------------- Public ----------------------------------------

    -------------------------------------------------------------------------
    --- Lua has no built in way to count number of values in an associative table so this does.
    -- @return number of values
    function dd:count()
        local num = 0
        for _, _ in pairs(dd) do
            num = num + 1
        end
        return num
    end

    -------------------------------------------------------------------------
    --- Get all the keys.
    -- @return List object of keys
    function dd:keys()
        local res = {}
        for k, _ in pairs(dd) do
            table.insert(res, k)
        end
        return List(res)
    end

    -------------------------------------------------------------------------
    --- Get all the values.
    -- @return List object of values
    function dd:values()
        local res = {}
        for _, v in pairs(dd) do
            table.insert(res, v)
        end
        return List(res)
    end

    -------------------------------------------------------------------------
    --- Merge the other table into this. Overwrites existing keys if that matters.
    -- @param other table to add
    function dd:add_range(other)
        lt.val_table(other, 1)
        for k, v in pairs(other) do
            -- check_val(other[i])
            dd[k] = v
        end
    end

    -------------------------------------------------------------------------
    --- Empty the table.
    function dd:clear()
        for k, _ in pairs(dd) do
            dd[k] = nil
        end
    end

    -----------------------------------------------------------------------------
    --- Tests if the value is in the table.
    -- @param tbl the table
    -- @param val the value
    -- @return corresponding key or nil if not
    function dd:contains_value(tbl, val)
        for k, v in pairs(tbl) do
            if v == val then return k end
        end
        return nil
    end

    -----------------------------------------------------------------------------
    -- Shallow copy of tbl.
    -- @param tbl the table
    -- @return new table
    function dd:copy(tbl)
        local res = {}
        for k, v in pairs(tbl) do
            res[k] = v
        end
        return res
    end


    ------------------------- Initialization --------------------------------

    -------------------------------------------------------------------------
    -- Object has been created. Finish up data initialization.
    setmetatable(dd,
    {
        name = name or 'no_name',
        class = 'Tableex',
        key_type = key_type,
        value_type = value_type,
        __tostring = function(self) return string.format('%s:(%s:%s)[%d] "%s"',
                        self:class(), self:key_type(), self:value_type(), self:count(), self:name()) end,
        -- __call = function(...) print('__call', ...) end,
    })

    -- Copy the data.
    dd:add_range(t)

    return dd
end

