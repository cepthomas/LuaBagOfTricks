-- A dictionary class in the lua prototype style. Each of keys and values must be homogenous.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modelled after C# instead of python.

local ut = require('lbot_utils')
local lt = require('lbot_types')
local tx = require('tableex')


-- The Dictionary class.
local Dictionary = {}

-------------------------------------------------------------------------
--- Create a Dictionary. It's a factory.
-- @param name optional name
-- @return a new Dictionary object
function Dictionary.new(name)

    -- Private fields.
    local _class = 'Dictionary'
    local _name = name
    local _key_type = 'nil'
    local _value_type = 'nil'
    local _data = {}

    -- Instance
    local dict = {}

    ------------------------ Properties -------------------------------------

    function dict:name() return _name end
    function dict:class() return _class end
    function dict:key_type() return _key_type end
    function dict:value_type() return _value_type end


    ------------------------- Private ---------------------------------------

    -------------------------------------------------------------------------
    --- Check type of key and value. Also does lazy init. Raises error.
    -- @param k the value to check
    -- @param v the value to check
    local function _check_kv(k, v)
        local check_ktype = ut.ternary(lt.is_integer(k), 'integer', type(k))
        local check_vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

        if tx.table_count(_data) == 0 then
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
                _key_type = ktype
            else
                error('Invalid key type: '..check_ktype)
            end

            if vtype ~= nil then
                _value_type = vtype
            else
                error('Invalid value type: '..check_vtype)
            end

        else -- adding to existing
            if check_ktype ~= _key_type then error('Keys not homogenous: '..check_ktype..' should be '.._key_type) end
            if check_vtype ~= _value_type then error('Values not homogenous: '..check_vtype..' should be '.._val_type) end
        end
    end


    ------------------------- Public ----------------------------------------

    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @param depth how deep to look
    -- @return string
    function dict:dump(depth)
        local s = tx.dump_table(_data, depth, _name)
        return s
    end

    -------------------------------------------------------------------------
    --- How many.
    -- @return number of values
    function dict:count()
        return tx.table_count(_data) --  A bit expensive so maybe cache size? TODOL
    end

    -------------------------------------------------------------------------
    --- Get all the keys.
    -- @return table of keys
    function dict:keys()
        local res = {}
        for k, _ in pairs(_data) do
            table.insert(res, k)
        end
        return res
    end

    -------------------------------------------------------------------------
    --- Get all the values.
    -- @return table of values
    function dict:values()
        local res = {}
        for _, v in pairs(_data) do
            table.insert(res, v)
        end
        return res
    end

    -------------------------------------------------------------------------
    --- Shallow copy the other table into this. Overwrites existing.
    -- @param other table to add
    function dict:add_range(other)
        lt.val_table(other, 1)
        -- shallow copy to our internal - validate
        for k, v in pairs(other) do
            _check_kv(k, v)
            -- tx.table_add(_data, k, v)
            _data[k] = v
        end
    end

    -------------------------------------------------------------------------
    --- Empty the table.
    function dict:clear()
        for k, _ in pairs(_data) do
            _data[k] = nil
        end
    end

    -------------------------------------------------------------------------
    --- Tests if the value is in the table.
    -- @param val the value
    -- @return corresponding key or nil if not
    function dict:contains_value(val)
        for k, v in pairs(_data) do
            if v == val then return k end
        end
        return nil
    end

    ------------------------- Finish ----------------------------------------

    local mt =
    {
        __index = function(t, index)
            return _data[index]
        end,
        __newindex = function(t, index, value)
             _check_kv(index, value)
             rawset(_data, index, value)
        end,
        __tostring = function(t)
            return string.format('%s(%s)[%s:%s]', _name, _class, _key_type, _value_type)
        end,
    }
    setmetatable(dict, mt)

    return dict
end


-------------------------------------------------------------------------
return Dictionary
