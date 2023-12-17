-- String utilities. ...

local M = {}

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
-- @param text The string to split.
-- @param delimiter Delimiter.
-- @return list Split input.
function M.strsplit(text, delimiter)
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
--- does s start with prefix or one of prefixes?
-- @string s a string
-- @param prefix a string or an array of strings
function M.startswith(s, prefix)
    assert_string(1, s)
    return test_affixes(s, prefix, raw_startswith)
end

-----------------------------------------------------------------------------
--- does s end with suffix or one of suffixes?
-- @string s a string
-- @param suffix a string or an array of strings
function M.endswith(s, suffix)
    assert_string(1, s)
    return test_affixes(s, suffix, raw_endswith)
end

local function raw_startswith(s, prefix)
    return find(s, prefix, 1, true) == 1
end

local function raw_endswith(s, suffix)
    return #s >= #suffix and find(s, suffix, #s-#suffix+1, true) and true or false
end


-----------------------------------------------------------------------------
-- Return the module.
return M
