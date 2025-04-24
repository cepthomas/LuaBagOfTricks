-- A dictionary class in the lua prototype style. Each of keys and values must be homogenous.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.

local ut = require('lbot_utils')
local lt = require('lbot_types')
local tx = require('tableex')
local list = require('List')


-- The global class.
local Dictionary = {}

-------------------------------------------------------------------------
--- Create a Dictionary. It's a factory.
-- @param t map-like table to init the Dictionary, or nil for deferred
-- @param name optional name
-- @return a new Dictionary object
-- function Dictionary:new(t, name)
function Dictionary.new(t, name)
    -- The instance with real data.
    if t ~= nil then
        lt.val_table(t)
    end

    local dd = {}

    local mt =
    {
        -- Private fields.
        class = 'Dictionary',
        name = name,
        key_type='nil',
        value_type='nil',
        -- Metatable.
        __index = Dictionary,
        __tostring = function(t)
            local mt = getmetatable(t)
            return string.format('%s(%s)[%s:%s]', mt.name, mt.class, mt.key_type, mt.value_type)
        end,
        __newindex = function(t, index, value) rawset(t, index, value) end
    }
    -- print(type(dd))
    setmetatable(dd, mt)

    -- safe to add the data now
    dd:add_range(t)

    return dd
end


------------------------ Properties -------------------------------------

function Dictionary:name() return getmetatable(self).name end
function Dictionary:class() return getmetatable(self).class end
function Dictionary:key_type() return getmetatable(self).key_type end
function Dictionary:value_type() return getmetatable(self).value_type end


------------------------- Private ---------------------------------------

-------------------------------------------------------------------------
--- Check type of key and value. Also does lazy init. Raises error.
-- @param k the value to check
-- @param v the value to check
---@diagnostic disable-next-line: unused-local
function Dictionary:_check_kv(k, v)
    local check_ktype = ut.ternary(lt.is_integer(k), 'integer', type(k))
    local check_vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

    if self:count() == 0 then
        -- new object, check types
        local key_types = { 'number', 'integer', 'string' }
        local val_types = { 'number', 'integer', 'string', 'boolean', 'table', 'function' }
        local ktype = nil
        local vtype = nil

        for _, v in ipairs(key_types) do
            if v == check_ktype then ktype = check_ktype end
        end

        for _, v in ipairs(val_types) do
            if v == check_vtype then vtype = check_vtype end
        end

        if ktype ~= nil then
            local mt = getmetatable(self)
            mt.key_type = ktype
            setmetatable(self, mt)
        else
            error('Invalid key type: '..check_ktype)
        end

        if vtype ~= nil then
            local mt = getmetatable(self)
            mt.value_type = vtype
            setmetatable(self, mt)
        else
            error('Invalid value type: '..check_vtype)
        end

    else -- add to existing
        if check_ktype ~= self:key_type() then error('Keys not homogenous: '..check_ktype) end
        if check_vtype ~= self:value_type() then error('Values not homogenous '..check_vtype) end
    end
end

------------------------- Public ----------------------------------------

-------------------------------------------------------------------------
--- Diagnostic.
-- @param depth how deep to look
-- @return string
function Dictionary:dump(depth)
    local s = tx.dump_table(self, depth, self:name())
    return s
end

-------------------------------------------------------------------------
--- How many.
-- @return number of values
function Dictionary:count()
    return tx.table_count(self) --  A bit expensive so maybe cache size? TODOL
end

-------------------------------------------------------------------------
--- Get all the keys.
-- @return List object of keys
function Dictionary:keys()
    local res = {}
    for k, _ in pairs(self) do
        table.insert(res, k)
    end
    return list:new(res)
end

-------------------------------------------------------------------------
--- Get all the values.
-- @return List object of values
function Dictionary:values()
    local res = {}
    for _, v in pairs(self) do
        table.insert(res, v)
    end
    return list:new(res)
end

-------------------------------------------------------------------------
--- Shallow copy the other table into this. Overwrites existing.
-- @param other table to add
function Dictionary:add_range(other)
    lt.val_table(other, 1)
    -- shallow copy to our internal - validate
    for k, v in pairs(other) do
        self:_check_kv(k, v)
        self[k] = v
    end
end

-------------------------------------------------------------------------
--- Empty the table.
function Dictionary:clear()
    for k, _ in pairs(self) do
        self[k] = nil
    end
end

-------------------------------------------------------------------------
--- Tests if the value is in the table.
-- @param val the value
-- @return corresponding key or nil if not
function Dictionary:contains_value(val)
    for k, v in pairs(self) do
        if v == val then return k end
    end
    return nil
end

return Dictionary
