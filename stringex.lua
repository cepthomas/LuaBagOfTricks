-- String utilities.

local lt = require('lbot_types')

local M = {}

---------------------------------------------------------------
-- Simple interpolated string function. Modified from http://lua-users.org/wiki/StringInterpolation.
-- ex: interp( [[Hello {name}, welcome to {company}.]], { name = name, company = get_company_name() } )
-- @param str Source string.
-- @param vars Replacement values dict.
-- @return Formatted string.
function M.interp(str, vars)
    lt.val_string(str)
    if not vars then
        vars = str
        str = vars[1]
    end
    return (str:gsub("({([^}]+)})", function(whole, i) return vars[i] or whole end))
end

-----------------------------------------------------------------------------
-- Concat the contents of the parameter list, separated by the string delimiter.
-- Example: strjoin(", ", {"Anna", "Bob", "Charlie", "Dolores"})
-- Modified from http://lua-users.org/wiki/SplitJoin.
-- @param delimiter Delimiter.
-- @param list The pieces parts.
-- @return string Concatenated list.
function M.strjoin(delimiter, list)
    lt.val_string(delimiter)
    lt.val_table(list)
    local len = #list
    if len == 0 then
        return ""
    end
    local string = table.concat(list, delimiter)
    return string
end

-----------------------------------------------------------------------------
-- Split text into a list. Modified from http://lua-users.org/wiki/SplitJoin.
-- Consisting of the strings in text, separated by strings matching delimiter (which may be a pattern).
--   Example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
-- @param text The string to split.
-- @param delimiter Delimiter.
-- @param trim Remove leading and trailing whitespace, and empty entries. Default is true.
-- @return list Split input.
function M.strsplit(text, delimiter, trim)
    lt.val_string(text)
    lt.val_string(delimiter)
    trim = trim or false
    local list = {}
    local pos = 1

    while 1 do
        local first, last = text:find(delimiter, pos, true)
        if first then -- found?
            local s = text:sub(pos, first - 1)
            if trim then
                s = M.strtrim(s)
                if #s > 0 then
                    table.insert(list, s)
                end
            else
                table.insert(list, s)
            end
            pos = last + 1
        else -- no delim, take it all
            local s = text:sub(pos)
            if trim then
                s = M.strtrim(s)
                if #s > 0 then
                    table.insert(list, s)
                end
            else
                table.insert(list, s)
            end
            break
        end
    end
    return list
end

-----------------------------------------------------------------------------
-- Trims whitespace from both ends of a string.
-- Modified from http://lua-users.org/wiki/SplitJoin.
-- @param s The string to clean up.
-- @return string Cleaned up input string.
function M.strtrim(s)
    lt.val_string(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-----------------------------------------------------------------------------
--- does s contain the phrase?
-- @string s a string
-- @param phrase a string
function M.contains(s, phrase)
    lt.val_string(s)
    lt.val_string(phrase)
    local res = s:find(phrase, 1, true)
    return res and res >= 1
end

-----------------------------------------------------------------------------
--- does s start with prefix?
-- @string s a string
-- @param prefix a string
function M.startswith(s, prefix)
    lt.val_string(s)
    lt.val_string(prefix)
    return s:find(prefix, 1, true) == 1
end

-----------------------------------------------------------------------------
--- does s end with suffix?
-- @string s a string
-- @param suffix a string
function M.endswith(s, suffix)
    lt.val_string(s)
    lt.val_string(suffix)
    return #s >= #suffix and s:find(suffix, #s-#suffix+1, true) and true or false
end

-----------------------------------------------------------------------------
-- Return the module.
return M
