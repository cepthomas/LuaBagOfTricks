-- Enhancements to built in table. Some OOP flavor added.


local ut = require("lbot_utils")
local lt = require("lbot_types")
-- local sx = require("stringex")




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


local function makelist(t)
    return setmetatable(t, require('pl.List'))
end
]]


-----------------------------------------------------------------------------
--- Create a fancier table.
-- @param t map-like table to init the Tableex, or nil for deferred
-- @param name optional name
-- @return a new Tableex object
function Tableex(t, name)
    local tt = t or {} -- our storage
    lt.val_table(tt, 0)

    ------------------------ Properties -------------------------------------

    function tt:name() return getmetatable(tt).name end
    function tt:class() return getmetatable(tt).class end
    function tt:key_type() return getmetatable(tt).key_type end
    function tt:value_type() return getmetatable(tt).value_type end


    ------------------------- Private ---------------------------------------

    -------------------------------------------------------------------------
    --- Check type of key and value. Also does lazy init. Raises error. TODOF Typed version - see List.py.
    -- @param v the value to check
    ---@diagnostic disable-next-line: unused-local
    local function check_val(k, v)
        local ktype = ut.ternary(lt.is_integer(k), 'integer', type(k))
        local vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

        if tt:count() == 0 then
            -- new object, check types
            local valid_key_types = { 'number', 'string' }
            local valid_val_types = { 'number', 'string', 'boolean', 'table', 'function' }

            if tt:contains(valid_key_types, ktype) then
                local mt = getmetatable(tt)
                mt.key_type = ktype
                setmetatable(tt, mt)
            else
                error('Invalid key type:'..ktype)
            end

            if tt:contains(valid_val_types, vtype) then
                local mt = getmetatable(tt)
                mt.value_type = vtype
                setmetatable(tt, mt)
            else
                error('Invalid value type:'..vtype)
            end

        else
            if ktype ~= tt:key_type() then error('Keys not homogenous') end
            if vtype ~= tt:value_type() then error('Values not homogenous') end
        end
    end

    ------------------------- Public ----------------------------------------

    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @param depth how deep to look
    -- @return string
    function tt:dump(depth)
        local s = ut.dump_table(tt, tt:name(), depth)
        return s
    end

    -------------------------------------------------------------------------
    --- Lua has no built in way to count number of values in an associative table so this does.
    -- A bit expensive so cache size? TODOL
    -- @return number of values
    function tt:count()
        local num = 0
        for _, _ in pairs(tt) do
            num = num + 1
        end
        return num
    end

    -------------------------------------------------------------------------
    --- Get all the keys.
    -- @return List object of keys
    function tt:keys()
        local res = {}
        for k, _ in pairs(tt) do
            table.insert(res, k)
        end
        return List(res)
    end

    -------------------------------------------------------------------------
    --- Get all the values.
    -- @return List object of values
    function tt:values()
        local res = {}
        for _, v in pairs(tt) do
            table.insert(res, v)
        end
        return List(res)
    end

    -------------------------------------------------------------------------
    --- Merge the other table into this. Overwrites existing keys if that matters.
    -- @param other table to add
    function tt:add_range(other)
        lt.val_table(other, 1)
        for k, v in pairs(other) do
            -- check_val(other[i])
            tt[k] = v
        end
    end

    -------------------------------------------------------------------------
    --- Empty the table.
    function tt:clear()
        for k, _ in pairs(tt) do
            tt[k] = nil
        end
    end

    -----------------------------------------------------------------------------
    --- Tests if the value is in the table.
    -- @param val the value
    -- @return corresponding key or nil if not
    function tt:contains_value(val)
        for k, v in pairs(tt) do
            if v == val then return k end
        end
        return nil
    end

    -----------------------------------------------------------------------------
    -- Shallow copy of tbl.
    -- @param tbl the table
    -- @return new table
    function tt:copy(tbl)
        local res = {}
        for k, v in pairs(tbl) do
            res[k] = v
        end
        return res
    end


    ------------------------- Initialization --------------------------------

    -------------------------------------------------------------------------
    -- Object has been created. Finish up data initialization.
    setmetatable(tt,
    {
        name = name or 'no_name',
        class = 'Tableex',
        __tostring = function(self) return string.format('%s:(%s:%s)[%d] "%s"',
                        self:class(), self:key_type(), self:value_type(), self:count(), self:name()) end,
        -- __call = function(...) print('__call', ...) end,
    })

    -- Copy the data.
    -- tt:add_range(t)

    return tt
end

