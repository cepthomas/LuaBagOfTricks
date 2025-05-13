local sx = require('stringex')
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
function M.deep_copy(tbl)

    local function _copy(t, cache)
        if type(t) ~= 'table' then return t end
        if cache[t] then return cache[t] end

        -- else newly seen table
        local res = {}
        cache[t] = res
        local mt = getmetatable(t)

        for k, v in pairs(t) do
            k = _copy(k, cache)
            v = _copy(v, cache)
            res[k] = v
        end

        setmetatable(res, mt)
        return res
    end

    return _copy(tbl, {})
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
--- Diagnostic.
-- @param tbl What to dump.
-- @param name Visual optional
-- @param depth How deep to go in recursion. 0 or nil means just this level.
-- @return string of contents
function M.dump_table(tbl, name, depth)
    lt.val_table(tbl)
    name = name or 'anonymous'
    depth = depth or 0
    lt.val_integer(depth)
    local level = 0

    -- Worker function.
    local function _dump_table(_tbl, _name, _level)
        local res = {}
        local sindent = string.rep('    ', _level)
        table.insert(res, sindent.._name..'[T]')

        -- Do contents.
        sindent = sindent..'    '
        if M.table_count(_tbl) == 0 then
            table.insert(res, sindent..sindent..'EMPTY')
        else
            for k, v in pairs(_tbl) do
                if type(v) == 'table' then
                    if _level < depth then
                        _level = _level + 1
                        local trec = _dump_table(v, k, _level) -- recursion!
                        _level = _level - 1
                        for _, v2 in ipairs(trec) do
                            table.insert(res, v2)
                        end
                    else
                        table.insert(res, string.format('%s%s[%s]:%s[%s]', sindent, tostring(k), lt.short_type(k), tostring(v), lt.short_type(v)))
                    end
                else
                    table.insert(res, string.format('%s%s[%s]:%s[%s]', sindent, tostring(k), lt.short_type(k), tostring(v), lt.short_type(v)))
                end
            end
        end

        return res
    end

    -- Go.
    local res = _dump_table(tbl, name, level)

    return sx.strjoin('\n', res)
end

-----------------------------------------------------------------------------
--- Diagnostic. 
-- @param lst sequence-like table
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
