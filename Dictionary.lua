-- A dictionary class in the lua prototype style
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.
-- TODOL optional homogenous values.


local ut = require("lbot_utils")
local lt = require("lbot_types")
require('List')


-- The global class.
Dictionary = {}

-------------------------------------------------------------------------
--- Create a Dictionary.
-- @param t map-like table to init the Dictionary, or nil for deferred
-- @param name optional name
-- @return a new Dictionary object
function Dictionary:create(t, name)
    -- The instance with real data.
    local o = {}
    if t ~= nil then
        lt.val_table(o)
        o = ut.deep_copy(t)
    end

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
    setmetatable(o, mt)

    return o
end


------------------------ Properties -------------------------------------

function Dictionary:name() return getmetatable(self).name end
function Dictionary:class() return getmetatable(self).class end
function Dictionary:key_type() return getmetatable(self).key_type end
function Dictionary:value_type() return getmetatable(self).value_type end


------------------------- Private ---------------------------------------

-------------------------------------------------------------------------
--- Check type of key and value. Also does lazy init. Raises error.
-- @param dd table TODOL klunky
-- @param k the value to check
-- @param v the value to check
---@diagnostic disable-next-line: unused-local
local function check_kv(dd, k, v)
    local ktype = ut.ternary(lt.is_integer(k), 'integer', type(k))
    local vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

    if dd.count() == 0 then
        -- new object, check types
        local valid_key_types = { 'number', 'string' }
        local valid_val_types = { 'number', 'string', 'boolean', 'table', 'function' }


        -- if vtype == vt then
        --     local mt = getmetatable(ll)
        --     mt.value_type = vtype
        --     setmetatable(ll, mt)
        -- end

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
--- Diagnostic.
-- @param depth how deep to look
-- @return string
function Dictionary:dump(depth)
    local s = ut.dump_table(self, self:name(), depth)
    return s
end

-------------------------------------------------------------------------
--- Lua has no built in way to count number of values in an associative table so this does.
-- A bit expensive so maybe cache size? TODOL
-- @return number of values
function Dictionary:count()
    return ut.count_table(self)
end

-------------------------------------------------------------------------
--- Get all the keys.
-- @return List object of keys
function Dictionary:keys()
    local res = {}
    for k, _ in pairs(self) do
        table.insert(res, k)
    end
    return List(res)
end

-------------------------------------------------------------------------
--- Get all the values.
-- @return List object of values
function Dictionary:values()
    local res = {}
    for _, v in pairs(self) do
        table.insert(res, v)
    end
    return List(res)
end

-------------------------------------------------------------------------
--- Merge the other table into this. Overwrites existing keys if that matters.
-- @param other table to add
function Dictionary:add_range(other)
    lt.val_table(other, 1)
    -- copy and add to our internal
    local to = ut.deep_copy(other)
    for k, v in pairs(to) do
        -- check_kv(self, k, v)
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
