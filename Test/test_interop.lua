-- Unit tests for interop processor. TODO

ut = require("utils")

local M = {}


-----------------------------------------------------------------------------
function M.setup(pn)
    -- pn.UT_INFO("setup()!!!")
end

-----------------------------------------------------------------------------
function M.teardown(pn)
    -- pn.UT_INFO("teardown()!!!")
end

-----------------------------------------------------------------------------
function M.suite_interop(pn)
    pn.UT_INFO("Test all functions in process_interop.lua")

    tm, msg = loadfile("C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\gen_interop.lua")

    print(tm, msg)

    if tm then
        tm("-cs", "-d", "-t", "Test\\interop_spec.lua", "Test\\out\\GeneratedInterop.cs")
    else
        pn.UT_ERROR("Error: "..msg)
    end
end

-----------------------------------------------------------------------------
-- Return the module.
return M
