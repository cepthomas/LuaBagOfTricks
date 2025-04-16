-- TODOL A typed dictionary class in the lua prototype style with homogenous values.
-- Parts are lifted from or inspired by https://github.com/lunarmodules/Penlight.
-- API names are modedded after C# instead of python.

local ut = require("lbot_utils")
local lt = require("lbot_types")
local tx = require("tableex")
local sx = require("stringex")
local ls = require("List")

-- update(table)   update the map using key/value pairs from another table. => append/add_range?
-- find_all(func, arg)
-- foreach(func, ...)

-----------------------------------------------------------------------------
--- Create a typed list.
-- @param t map-like table to init the Dictionary, or nil for deferred
-- @param name optional name
-- @return a new Dictionary object
function Dictionary(t, name)
    if t ~= nil and type(t) ~= 'table' then error('Invalid initializer: '..type(t)) end
    local dd = {} -- our storage
    local value_type = nil -- default

    -------------------------------------------------------------------------
    -- Properties
    function dd:name() return getmetatable(dd).name end
    function dd:key_type() return getmetatable(dd).key_type end
    function dd:value_type() return getmetatable(dd).value_type end

    -------------------------------------------------------------------------
    --- Diagnostic.
    -- @return a string
    function dd:dump()
        local res = {}
        table.insert(res, 'Dictionary('..dd:key_type()..':'..dd.value_type..') ['..dd:name()..']')
        for k, v in pairs(dd) do
            table.insert(res, '    '..k..':'..v)
        end
        return sx.strjoin('\n', res)
    end

    -------------------------------------------------------------------------
    --- Check type of key and value. Also does lazy init. Raises error.
    -- @param v the value to check
    local function check_val(k, v)
        local ktype = ut.ternary(lt.is_integer(k), 'integer', type(k))
        local vtype = ut.ternary(lt.is_integer(v), 'integer', type(v))

        if tx.count(dd) == 0 then -- TODOL cache size?
            -- new object, check types
            local valid_key_types = { 'number', 'string' }
            local valid_val_types = { 'number', 'string', 'boolean', 'table', 'function' }
            if tx.contains(valid_types, vtype) then
                local mt = getmetatable(dd)
                mt.value_type = vtype
                setmetatable(dd, mt)
            else
                error('Invalid value type:'..vtype)
            end
        else
            -- add, check type
            if vtype ~= dd:value_type() then error('Values not homogenous') end
        end
    end

    -------------------------------------------------------------------------
    --- How many.
    -- @return the count
    function dd:count()
        return tx.count(dd)
    end

    -------------------------------------------------------------------------
    ---
    -- @return list of keys
    function dd:keys()
        return tx.count(dd)
    end

    -------------------------------------------------------------------------
    ---
    -- @return list of values
    function dd:values()
        return tx.count(dd)
    end

    -------------------------------------------------------------------------
    --- put a value into the map. combine: pl.Map:setdefault(key, default)    set a value in the map if it doesn't exist yet.
    function dd:set(key, val)
        return tx.count(dd)
    end

    -------------------------------------------------------------------------
    --- get a value from the map
    -- @return the value or nil
    function dd:get(key)
        return tx.count(dd)
    end

    -------------------------------------------------------------------------
    --- Empty the list.
    -- @return the list
    function dd:clear()
        for _ = 1, tx.count(dd) do table.remove(dd) end
        return dd
    end

    -------------------------------------------------------------------------
    -- Good to go. Do meta stuff, properties.
    setmetatable(dd,
    {
        name = name or 'no-name',
        value_type = value_type,
        __tostring = function(self) return 'Dictionary:['..self:name()..'] type:'..self:value_type()..' len:'..tostring(self:count()) end,
        -- __call = function(...) print('__call', ...) end,
    })

    if t ~= nil then
        -- -- TODOL? Check that the table is array-like.
        -- -- Check if all keys are indexes.
        -- local num = 0
        -- for k, _ in pairs(t) do
        --     if type(k) ~= 'number' then error('Indexes must be number') end
        --     num = num + 1
        -- end

        -- -- Check sequential from 1.
        -- for i = 1, num do
        --     if t[i] == nil then error('Indexes must be sequential') end
        -- end

        -- Copy the data. This tests for homogenity.
        for _, v in ipairs(t) do dd:add(v) end
    end

    return dd
end

