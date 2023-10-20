--[[
GP utilities: strings, tables, math, ...
--]]


-- Create the namespace/module.
local M = {}


function M.execute_capture(cmd)
  local f = io.popen(cmd, 'r')
  local s = f:read('*a')
  f:close()
  -- if raw then return s end
  -- s = string.gsub(s, '^%s+', '')
  -- s = string.gsub(s, '%s+$', '')
  -- s = string.gsub(s, '[\n\r]+', ' ')
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
-- @param short Return simple string.
-- @return string or array dump.
function M.dump_table(tbl, indent, short)
    local res = {}

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

    if short ~= nil then
        res = M.strjoin('\n', res)
    end

    return res
end
-- TODO1 Make prettier, identify array/list/map/dict
-- 1(table):
--     description:booga(string)
--     host_func_name:interop_HostCallLua(string)
--     lua_func_name:my_lua_func(string)
--     ret(table):
--         description:a returned thing(string)
--         type:T(string)
--     args(table):
--         1(table):
--             type:S(string)
--             description:some strings(string)
--             name:arg_one(string)
--         2(table):
--             type:I(string)
--             description:a nice integer(string)
--             name:arg_two(string)
--         3(table):
--             type:T(string)
--             description:3 ddddddddd(string)
--             name:arg_three(string)
-- 2(table):
--     description:booga2(string)
--     host_func_name:interop_HostCallLua2(string)
--     lua_func_name:my_lua_func2(string)
--     ret(table):
--         description:a returned number(string)
--         type:N(string)
--     args(table):
--         1(table):
--             type:B(string)
--             description:bbbbbbb(string)
--             name:arg_one(string)

-----------------------------------------------------------------------------
-- Gets the file and line of the caller.
-- @param level Where to look.
-- @return array of info or nil if invalid
function M.get_caller_info(level)
    local ret = nil
    local s = debug.getinfo(level, 'S')
    local l = debug.getinfo(level, 'l')
    if s ~= nil or l ~= nil then
        ret = { s.source:gsub("@", ""), l.currentline }
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
-- Return the module.
return M
