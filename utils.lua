
local api = require("neb_api_sim") -- TODO1 do better

-- Create the namespace/module.
local M = {}

-- Defs from the C# logger side.
M.LOG_TRACE = 0
M.LOG_DEBUG = 1
M.LOG_INFO = 2
M.LOG_WARN = 3
M.LOG_ERROR = 4

-- Convenience functions.
function M.error(msg) api.log(M.LOG_ERROR, msg) end
function M.warn(msg) api.log(M.LOG_WARN, msg) end
function M.info(msg) api.log(M.LOG_INFO, msg) end
function M.debug(msg) api.log(M.LOG_DEBUG, msg) end



-----------------------------------------------------------------------------
-- TODO1 fix/test this
function M.dump_table(tbl, indent)
    res = {}

    for k, v in pairs(tbl) do
        table.insert(res, k .. ":" .. "(" .. type(v) .. ")")
    end

    -- for k, v in pairs(tbl) do
    --     if type(v) == "table" then
    --         table.insert(res, M.dump_table(v, indent + 1)) -- recursion!
    --     else
    --         table.insert(res, k .. ":" .. "(" .. type(v) .. ")")
    --     end
    -- end
    return M.strjoin('\n', res)
end                

-----------------------------------------------------------------------------
-- Gets the file and line of the test script.
-- @param level Where to look.
-- @return array of info or nil if invalid
function M.get_caller_info(level)
    ret = nil
    s = debug.getinfo(level, 'S')
    l = debug.getinfo(level, 'l')
    if s ~= nil or l ~= nil then
        ret = { s.source:gsub("@", ""), l.currentline }
    end
    return ret
end


-----------------------------------------------------------------------------
-- Generate a sequence of values from the source table.
-- @param source Source table.
-- @return next() - Function that returns value.
function M.array_seq(source)
    -- Init our copies of the args.
    local t = source
    local n = 1 -- next value

    -- The accessor function.
    local next =
    function()
        -- Save the return value.
        ret = t[n]
        -- Calc the next index.
        n = n + 1
        if n > #t then n = 1 end
        return ret
    end

    return {next = next}
end


-----------------------------------------------------------------------------
-- Get array from a file.
-- Will coerce to number if all are valid - TODO3 Doesn't appear to be true - test/repair.
-- Adds an array value for each LF and each csv value.
-- @param filename Filename.
-- @param rem_blanks True if blank fields should be removed (optional).
-- @return table File data.
function M.array_from_file(filename, rem_blanks)
    if rem_blanks == nil then rem_blanks = false end

    t = {}
    for line in io.lines(filename) do
        vals = M.strsplit(",", line)
        if vals ~= nil then
            for i, v in ipairs(vals) do
                s = M.strtrim(v)
                if rem_blanks == false or #s > 0 then
                    table.insert(t, M.strtrim(v))
                end
            end
        end
    end

    return t
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
    local string = list[1]
    for i = 2, len do
        string = string .. delimiter .. list[i]
    end
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
