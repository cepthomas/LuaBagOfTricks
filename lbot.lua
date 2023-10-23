-- Internal stuff: debugger, and error handling, ...

local M = {}

local og_error = error -- save original func
local enb_debugger
local enb_term
local have_debugger

function M.config_error_handling(dbgr, term)
    enb_debugger = dbgr
    enb_term = term

    if enb_debugger then
        have_debugger, dbg = pcall(require, "debugger")
        if not have_debugger then
            print(dbg)
        end
    end

    if dbg then 
        -- sub debug handler
        error = dbg.error
    end

    if dbg and enb_term then
        dbg.enable_color()
    end

    -- Make a global stub to keep breakpoints from yelling.
    if not dbg then
        function dbg() end
    end

    -- print(enb_debugger, have_debugger, enb_term, dbg)
    -- dbg()
end

return M
