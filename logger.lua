--[[
Simple logger, will get more.
--]]


-- Create the namespace/module.
local M = {}

-- Defs from the C# logger side.
M.LOG_TRACE = 0
M.LOG_DEBUG = 1
M.LOG_INFO = 2
M.LOG_WARN = 3
M.LOG_ERROR = 4

-- Main function.
function M.log(level, msg)
    marker = ""
    if level == M.LOG_WARN then maker = "? "
    elseif level == M.LOG_ERROR then maker = "! "
    end

    print(marker .. msg) -- TODO support user supplied streams.
end

-- Convenience functions.
function M.error(msg) M.log(M.LOG_ERROR, msg) end
function M.warn(msg) M.log(M.LOG_WARN, msg) end
function M.info(msg) M.log(M.LOG_INFO, msg) end
function M.debug(msg) M.log(M.LOG_DEBUG, msg) end


-----------------------------------------------------------------------------
-- Return the module.
return M
