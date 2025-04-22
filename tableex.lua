-- TODOF others from https://lunarmodules.github.io/Penlight/libraries/pl.tablex.html

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
        local mt = getmetatable(t)
        for k, v in pairs(t) do
            k = _copy_table(k, cache)
            v = _copy_table(v, cache)
            res[k] = v
        end
        setmetatable(res,mt)
        return res
    end

    return _copy_table(t, {})
end


-----------------------------------------------------------------------------
--- Diagnostic.
-- @param tbl What to dump.
-- @param name Visual optional
-- @param depth How deep to go in recursion. 0 (default) means just this level.
-- @return formatted string
function M.dump_table(tbl, depth, name)
    lt.val_table(tbl)
    name = name or 'noname'
    depth = depth or 0
    lt.val_integer(depth)
    local level = 0

    -- Worker function.
    local function _dump_table(_tbl, _name, _level)
        local res = {}
        local sindent = string.rep('    ', _level)
        table.insert(res, sindent.._name..'(table):')

        -- Do contents.
        sindent = sindent..'    '
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
                    table.insert(res, sindent..k..'('..type(v)..')')
                end
            else
                table.insert(res, sindent..k..'('..type(v)..')['..tostring(v)..']')
            end
        end

        return res
    end

    -- Go.
    local res = _dump_table(tbl, name, level)

    return sx.strjoin('\n', res)
end

--[[
-----------------------------------------------------------------------------
--- Diagnostic.
-- @param tbl What to dump.
-- @param depth How deep to go in recursion. 0 means just this level.
-- @param name Of the tbl.
-- @param indent Nesting.
-- @return list table of strings
function M.dump_table(tbl, depth, name, indent)
    local res = {}
    indent = indent or 0
    name = name or "no_name"

    if type(tbl) == "table" then
        local sindent = string.rep("    ", indent)
        table.insert(res, sindent..name.."(table):")

        -- Do contents.
        indent = indent + 1
        sindent = sindent.."    "
        for k, v in pairs(tbl) do
            if type(v) == "table" and _dump_level < depth then
                _dump_level = _dump_level + 1
                local trec = M.dump_table(v, depth, k, indent) -- recursion!
                _dump_level = _dump_level - 1
                for _, v2 in ipairs(trec) do
                    table.insert(res, v2)
                end
            else
                table.insert(res, sindent..k..":"..tostring(v).."("..type(v)..")")
            end
        end
    else
        table.insert(res, "Not a table")
    end

    return res
end

-----------------------------------------------------------------------------
--- Diagnostic. Dump table as formatted strings.
-- @param tbl What to dump.
-- @param depth How deep to go in recursion. 0 means just this level.
-- @param name Of tbl.
-- @return string Formatted/multiline contents
function M.dump_table_string(tbl, depth, name)
    local res = M.dump_table(tbl, depth, name, 0)
    return sx.strjoin('\n', res)
end
]]

-----------------------------------------------------------------------------
--- Diagnostic. 
-- @param lst What to dump.
-- @return string Comma delim line of contents.
function M.dump_list(lst)
    local res = {}
    for _, l in ipairs(lst) do
        table.insert(res, l)
    end
    return sx.strjoin(',', res)
end

-------------------------------------------------------------------------
--- Get all the keys.
-- @return List object of keys
function M.keys()
    local res = {}
    for k, _ in pairs(self) do
        table.insert(res, k)
    end
    return List(res)
end

-------------------------------------------------------------------------
--- Get all the values.
-- @return List object of values
function M.values()
    local res = {}
    for _, v in pairs(self) do
        table.insert(res, v)
    end
    return List(res)
end

-------------------------------------------------------------------------
--- Merge the other table into this. Overwrites existing keys if that matters.
-- @param other table to add
function M.add_range(other)
    lt.val_table(other, 1)
    -- copy and add to our internal
    local to = ut.deep_copy(other)
    for k, v in pairs(to) do
        -- check_val(other[i])
        self[k] = v
    end
end

-------------------------------------------------------------------------
--- Empty the table.
function M.clear()
    for k, _ in pairs(self) do
        self[k] = nil
    end
end

-----------------------------------------------------------------------------
--- Tests if the value is in the table.
-- @param val the value
-- @return corresponding key or nil if not
function M.contains_value(val)
    for k, v in pairs(self) do
        if v == val then return k end
    end
    return nil
end

-----------------------------------------------------------------------------
-- Deep copy tbl to internal.
-- @param tbl the table
-- @return new table
function M.copy(tbl)
    local res = {}
    for k, v in pairs(tbl) do
        res[k] = v
    end
    return res
end







-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------



-- -------------------------------------------------------------------------
-- --- Diagnostic.
-- -- @param depth how deep to look
-- -- @return string
-- function M.dump(depth)
--     local s = ut.dump_table(self, self.name, depth)
--     return s
-- end

-- -------------------------------------------------------------------------
-- --- Lua has no built in way to count number of values in an associative table so this does.
-- -- A bit expensive so cache size? TODOL
-- -- @return number of values
-- function M.count()
--     local num = 0
--     for _, _ in pairs(self) do
--         num = num + 1
--     end
--     return num
-- end



-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- --- Get all the keys of tbl.
-- -- @param tbl the table
-- -- @return list of keys
-- function M.keys(tbl)
--     local res = {}
--     for k, _ in pairs(tbl) do
--         table.insert(res, k)
--     end
--     return res
-- end

-- -----------------------------------------------------------------------------
-- --- Get all the values of tbl.
-- -- @param tbl the table
-- -- @return list of values
-- function M.values(tbl)
--     local res = {}
--     for _, v in pairs(tbl) do
--         table.insert(res, v)
--     end
--     return res
-- end


-----------------------------------------------------------------------------
--- Tests if the value is in the table.
-- @param tbl the table
-- @param val the value
-- @return T/F
function M.contains(tbl, val)
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



-- For table dumping.
local _dump_level = 0



-----------------------------------------------------------------------------
-- Return the module.
return M
