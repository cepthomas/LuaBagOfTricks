--[[
GP utilities.
--]]


-- Create the namespace/module.
local M = {}


-----------------------------------------------------------------------------
-- @param tbl What to dump.
-- @param indent Nesting.
-- @return string array dump.
function M.dump_table(tbl, indent)
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

    return res
end                

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
-- Return the module.
return M
