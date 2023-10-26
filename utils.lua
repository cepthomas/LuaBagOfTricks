-- GP utilities: strings, tables, math, validation, errors, ...

local M = {}


---------------------------------------------------------------
-- Execute a file and return the output.
-- @param cmd Command to run.
-- @return Output text.
function M.execute_capture(cmd)
  local f = io.popen(cmd, 'r')
  local s = f:read('*a')
  f:close()
  return s
end

---------------------------------------------------------------
-- Simple interpolated string function. Stolen/modified from http://lua-users.org/wiki/StringInterpolation.
-- ex: interp( [[Hello {name}, welcome to {company}.]], { name = name, company = get_company_name() } )
-- @param str Source string.
-- @param vars Replacement values dict.
-- @return Formatted string.
function M.interp(str, vars)
    if not vars then
        vars = str
        str = vars[1]
    end
    return (string.gsub(str, "({([^}]+)})", function(whole, i) return vars[i] or whole end))
end

-----------------------------------------------------------------------------
-- Diagnostic.
-- @param tbl What to dump.
-- @param indent Nesting.
-- @return string list
function M.dump_table(tbl, indent) --TODO add table name
    local res = {}
    indent = indent or 0

    if type(tbl) == "table" then
        local sindent = string.rep("    ", indent)

        for k, v in pairs(tbl) do
            if type(v) == "table" then
                table.insert(res, sindent .. k .. "(table):")
                t2 = M.dump_table(v, indent + 1) -- recursion!
                for _,v in ipairs(t2) do
                    table.insert(res, v)
                end
            else
                table.insert(res, sindent .. k .. ":" .. tostring(v) .. "(" .. type(v) .. ")")
            end
        end
    else
        table.insert(res, "Not a table")
    end

    return res
end

-----------------------------------------------------------------------------
-- Diagnostic.
-- @param tbl What to dump.
-- @return string list
function M.dump_table_string(tbl)
    local res = M.dump_table(tbl, 0)
    return M.strjoin('\n', res)
end

-----------------------------------------------------------------------------
-- Gets the file and line of the caller.
-- @param level How deep to look:
--    0 is the getinfo() itself
--    1 is the function that called getinfo() - get_caller_info()
--    2 is the function that called get_caller_info() - usually the one of interest
-- @return { filename, linenumber } or nil if invalid
function M.get_caller_info(level)
    local ret = nil
    local s = debug.getinfo(level, 'S')
    local l = debug.getinfo(level, 'l')
    if s ~= nil and l ~= nil then
        ret = { s.short_src, l.currentline }
    end
    return ret
end

-----------------------------------------------------------------------------
-- Concat the contents of the parameter list, separated by the string delimiter.
-- Example: strjoin(", ", {"Anna", "Bob", "Charlie", "Dolores"})
-- Borrowed from http://lua-users.org/wiki/SplitJoin.
-- @param delimiter Delimiter.
-- @param list The pieces parts.
-- @return string Concatenated list.
function M.strjoin(delimiter, list)
    local len = #list
    if len == 0 then
        return ""
    end
    local string = table.concat(list, delimiter)
    -- local string = list[1]
    -- for i = 2, len do
    --     string = string .. delimiter .. list[i]
    -- end
    return string
end

-----------------------------------------------------------------------------
-- Split text into a list.
-- Consisting of the strings in text, separated by strings matching delimiter (which may be a pattern).
--   Example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
--   Borrowed from http://lua-users.org/wiki/SplitJoin.
-- @param delimiter Delimiter.
-- @param text The string to split.
-- @return list Split input.
function M.strsplit(delimiter, text)
    local list = {}
    local pos = 1
    if string.find("", delimiter, 1) then -- this would result in endless loops
        error("Delimiter matches empty string.")
    end
    while 1 do
        local first, last = string.find(text, delimiter, pos)
        if first then -- found?
            table.insert(list, string.sub(text, pos, first - 1))
            pos = last + 1
        else
            table.insert(list, string.sub(text, pos))
            break
        end
    end
    return list
end

-----------------------------------------------------------------------------
-- Trims whitespace from both ends of a string.
-- Borrowed from http://lua-users.org/wiki/SplitJoin.
-- @param s The string to clean up.
-- @return string Cleaned up input string.
function M.strtrim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-----------------------------------------------------------------------------
-- Remap a value to new coordinates.
-- @param val
-- @param start1
-- @param stop1
-- @param start2
-- @param stop2
-- @return
function M.map(val, start1, stop1, start2, stop2)
    return start2 + (stop2 - start2) * (val - start1) / (stop1 - start1)
end

-----------------------------------------------------------------------------
-- Bounds limits a value.
-- @param val
-- @param min
-- @param max
-- @return
function M.constrain(val, min, max)
    val = math.max(val, min)
    val = math.min(val, max)
    return val
end

-----------------------------------------------------------------------------
-- Ensure integral multiple of resolution, GTE min, LTE max.
-- @param val
-- @param min
-- @param max
-- @param resolution
-- @return
function M.constrain(val, min, max, resolution)
    rval = constrain(val, min, max)
    rval = math.round(rval / resolution) * resolution
    return rval
end

-----------------------------------------------------------------------------
-- Snap to closest neighbor.
-- @param val
-- @param granularity">The neighbors property line.
-- @param round">Round or truncate.
-- @return
function M.clamp(val, granularity, round)
    res = (val / granularity) * granularity
    if round and (val % granularity > granularity / 2) then res = res + granularity end
    return res
end

-----------------------------------------------------------------------------
function M.is_integer(v) return math.ceil(v) == v end
function M.is_number(v) return type(v) == 'number' end
function M.is_string(v) return type(v) == 'string' end
function M.is_boolean(v) return type(v) == 'boolean' end
function M.is_function(v) return type(v) == 'function' end
function M.is_table(v) return type(v) == 'table' end

-----------------------------------------------------------------------------
function M.val_number(v, max, min)
    local ok = M.is_number(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        local s = string.format("Invalid number:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_integer(v, max, min)
    local ok = M.is_integer(v)
    ok = ok and (max ~= nil and v <= max)
    ok = ok and (min ~= nil and v >= min)
    if not ok then
        local s = string.format("Invalid integer:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_string(v)
    local ok = M.is_string(v)
    if not ok then
        local s = string.format("Invalid string:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_boolean(v)
    local ok = M.is_boolean(v)
    if not ok then
        local s = string.format("Invalid boolean:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_table(v)
    local ok = M.is_table(v)
    if not ok then
        local s = string.format("Invalid table:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
function M.val_function(v)
    local ok = M.is_function(v)
    if not ok then
        local s = string.format("Invalid function:%s", tostring(v))
        error(s, 2) -- who called me
    end
end

-----------------------------------------------------------------------------
-- Return the module.
return M
