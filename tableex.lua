local sx = require("stringex")
local lt = require('lbot_types')

local M = {}


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
--- Make a deep copy of a table, including metatables.
-- @param t to copy
-- @return new table
function M.deep_copy(t)

    local function _copy_table(t, cache)
        if type(t) ~= 'table' then return t end
        if cache[t] then return cache[t] end
        -- assert_arg_iterable(1,t)
        local res = {}
        cache[t] = res
        -- local mt = getmetatable(t)
        for k, v in pairs(t) do
            k = _copy_table(k, cache)
            v = _copy_table(v, cache)
            res[k] = v
        end
        setmetatable(res, getmetatable(t))
        return res
    end

    return _copy_table(t, {})
end

-----------------------------------------------------------------------------
--- Tests if the value is in the table.
-- @param tbl the table
-- @param val the value
-- @return corresponding key or nil if not
function M.contains_value(tbl, val)
    for _, v in pairs(tbl) do
        if v == val then return true end
    end
    return false
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
--- Diagnostic.
-- @param tbl What to dump.
-- @param name Visual optional
-- @param depth How deep to go in recursion. 0 (default) means just this level.
-- @return string of contents
function M.dump_table(tbl, depth, name)
    lt.val_table(tbl)
    name = name or 'noname'
    depth = depth or 0
    lt.val_integer(depth)
    local level = 0

    -- Worker function.
    local function _dump_table(_tbl, _level, _name)
        local res = {}
        local sindent = string.rep('    ', _level)
        table.insert(res, sindent.._name..'(table):')

        -- Do contents.
        if #_tbl == 0 then
            table.insert(res, sindent..sindent..'EMPTY')
        else
            sindent = sindent..'    '
            for k, v in pairs(_tbl) do
                if type(v) == 'table' then
                    if _level < depth then
                        _level = _level + 1
                        local trec = _dump_table(v, _level, k) -- recursion!
                        _level = _level - 1
                        for _, v2 in ipairs(trec) do
                            table.insert(res, v2)
                        end
                    else
                        table.insert(res, sindent..k..'('..type(v)..')')
                    end
                else
                    table.insert(res, sindent..k..'('..type(v)..')['..tostring(v)..']')
                end
            end
        end

        return res
    end

    -- Go.
    local res = _dump_table(tbl, level, name)

    return sx.strjoin('\n', res)
end

-----------------------------------------------------------------------------
--- Diagnostic. 
-- @param lst array-like table
-- @return string Comma delim values
function M.dump_list(lst)
    local res = {}
    for _, l in ipairs(lst) do
        table.insert(res, l)
    end
    return sx.strjoin(',', res)
end


-----------------------------------------------------------------------------
-- Return the module.
return M
