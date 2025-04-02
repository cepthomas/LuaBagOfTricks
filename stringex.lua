-- String utilities.

-- TODOL Add some from https://lunarmodules.github.io/Penlight/libraries/pl.stringx.html
--[[
Dependencies: pl.utils, pl.types

String Predicates
isalpha (s)     does s only contain alphabetic characters?
isdigit (s)     does s only contain digits?
isalnum (s)     does s only contain alphanumeric characters?
isspace (s)     does s only contain whitespace?
islower (s)     does s only contain lower case characters?
isupper (s)     does s only contain upper case characters?
startswith (s, prefix)  does s start with prefix or one of prefixes?
endswith (s, suffix)    does s end with suffix or one of suffixes?

Strings and Lists
join (s, seq)   concatenate the strings using this string as a delimiter.
splitlines (s[, keep_ends])     Split a string into a list of lines.
split (s[, re[, n] ])    split a string into a list of strings using a delimiter.
expandtabs (s, tabsize)     replace all tabs in s with tabsize spaces.

Finding and Replacing
lfind (s, sub[, first[, last] ])     find index of first instance of sub in s from the left.
rfind (s, sub[, first[, last] ])     find index of first instance of sub in s from the right.
replace (s, old, new[, n])  replace up to n instances of old by new in the string s.
count (s, sub[, allow_overlap])     count all instances of substring in string.

Stripping and Justifying
ljust (s, w[, ch=' '])  left-justify s with width w.
rjust (s, w[, ch=' '])  right-justify s with width w.
center (s, w[, ch=' '])     center-justify s with width w.
lstrip (s[, chrs='%s'])     trim any characters on the left of s.
rstrip (s[, chrs='%s'])     trim any characters on the right of s.
strip (s[, chrs='%s'])  trim any characters on both left and right of s.

Partitioning Strings
splitv (s[, re='%s'])   split a string using a pattern.
partition (s, ch)   partition the string using first occurrence of a delimiter
rpartition (s, ch)  partition the string p using last occurrence of a delimiter
at (s, idx)     return the 'character' at the index.

Text handling
indent (s, n[, ch=' '])     indent a multiline string.
dedent (s)  dedent a multiline string by removing any initial indent.
wrap (s[, width=70[, breaklong=false] ])     format a paragraph into lines so that they fit into a line width.
fill (s[, width=70[, breaklong=false] ])     format a paragraph so that it fits into a line width.

Miscellaneous
lines (s)   return an iterator over all lines in a string
title (s)   initial word letters uppercase ('title case').
shorten (s, w, tail)    Return a shortened version of a string.
quote_string (s)    Quote the given string and preserve any control or escape characters, such that reloading the string in Lua returns the same result.
format_operator ()  Python-style formatting operator.
import ()   import the stringx functions into the global string (meta)table

]]

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
    return (str:gsub("({([^}]+)})", function(whole, i) return vars[i] or whole end))
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
-- @param trim Remove leading and trailing whitespace, and empty entries.
-- @return list Split input.
function M.strsplit(text, delimiter, trim)
    local list = {}
    local pos = 1

    if text == nil then
        return {}
    end

    if string.find("", delimiter, 1, true) then -- this would result in endless loops
        error("Delimiter matches empty string.")
    end

    while 1 do
        local first, last = text:find(delimiter, pos, true)
        if first ~= nil then -- found?
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
-- Borrowed from http://lua-users.org/wiki/SplitJoin.
-- @param s The string to clean up.
-- @return string Cleaned up input string.
function M.strtrim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-----------------------------------------------------------------------------
--- does s contain the phrase?
-- @string s a string
-- @param phrase a string
function M.contains(s, phrase)
    local res = s:find(phrase, 1, true)
    return res ~= nil and res >= 1
end

-----------------------------------------------------------------------------
--- does s start with prefix?
-- @string s a string
-- @param prefix a string
function M.startswith(s, prefix)
    return s:find(prefix, 1, true) == 1
end

-----------------------------------------------------------------------------
--- does s end with suffix?
-- @string s a string
-- @param suffix a string
function M.endswith(s, suffix)
    return #s >= #suffix and s:find(suffix, #s-#suffix+1, true) and true or false
end

-----------------------------------------------------------------------------
-- Return the module.
return M
