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
----------------------------- new TODO1 -------------------------------------------
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- Description
-- Description
-- @param name type desc
-- @return type desc


-- Remap a value to new coordinates.
-- @param val ??
-- @param start1 ??
-- @param stop1 ??
-- @param start2 ??
-- @param stop2 ??
-- @return ??
function M.map(val, start1, stop1, start2, stop2)
    return start2 + (stop2 - start2) * (val - start1) / (stop1 - start1)

-- Bounds limits a value.
-- @param val ??
-- @param min ??
-- @param max ??
-- @return ??
function M.constrain(val, min, max)
    val = math.max(val, min)
    val = math.min(val, max)
    return val

-- Ensure integral multiple of resolution, GTE min, LTE max.
-- @param val ??
-- @param min ??
-- @param max ??
-- @param resolution ??
-- @return ??
function M.constrain(val, min, max, resolution)
    rval = constrain(val, min, max)
    rval = math.round(rval / resolution) * resolution
    return rval

-- Snap to closest neighbor.
-- @param val ??
-- @param granularity">The neighbors property line.
-- @param round">Round or truncate.
-- @return ??
function M.clamp(val, granularity, round)
    res = (val / granularity) * granularity
    if (round && val % granularity > granularity / 2) then
        res += granularity
    end        
    return res



-----------------------------------------------------------------------------
----------------------------- errors ----------------------------------------
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
--- is this number an integer? from penlight
-- @param x a number
-- @raise error if x is not a number
-- @return boolean
function M.is_integer(x)
    return math.ceil(x) == x
end


--TODO1 errors: need gp arg checker: type, optional, range?
-- is_number(val)  is_string(val)  is_number_opt(val)  etc

-- error (message [, level])
-- Raises an error with message as the error object. This function never returns.
-- Usually, error adds some information about the error position at the beginning of the message, if the message is a string.
-- The level argument specifies how to get the error position. With level 1 (the default), the error position is where
-- the error function was called. Level 2 points the error to where the function that called error was called; and so on.
-- Passing a level 0 avoids the addition of error position information to the message.

-- If there are no errors during the call, lua_pcall behaves exactly like lua_call. However, if there is any error, 
-- lua_pcall catches it, pushes a single value on the stack (the error object), and returns an error code. 
-- Like lua_call, lua_pcall always removes the function and its arguments from the stack.

-- My_Error()
--     --Error Somehow
-- end
-- local success,err = pcall(My_Error)
-- if not success then
--     error(err)
-- end




-----------------------------------------------------------------------------
-- Return the module.
return M
