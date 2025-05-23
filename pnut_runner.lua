--[[
Performs test run discovery, management, report generation.
Can be run from the cmd line or require pnut_runner from another script/module.
Future opts maybe: write to file, junit/xml format.
--]]

local pn = require("pnut")
local ut = require("lbot_utils")

-- Create the namespace/module.
local M = {}

-- User can specify output file name.
M.report_fn = nil


-----------------------------------------------------------------------------
function M.do_tests(...)
    local func_arg = {...}
    pn.reset()

    local start_time = os.clock()
    local start_date = os.date()
    -- Indicates an app failure.
    local app_fail = false
    -- Indicates an error in the user script.
    local script_fail = false

    for i = 1, #func_arg do
        local scrfn = func_arg[i]

        -- load script by converting to module.
        local mod = scrfn:gsub('%.lua', '')

        -- Load file in protected mode.
        local load_ok, test_mod = pcall(require, mod)

        if not load_ok then
            app_fail = true
            pn.UT_ERROR("Failed to load file: "..scrfn)
        elseif type(test_mod) ~= "table" then
            app_fail = true
            pn.UT_ERROR("Not a valid test script: "..scrfn)
        else
            -- Dig out the test cases.
            for k, v in pairs(test_mod) do
                if type(v) == "function" and k:match("suite_") then
                    -- Found something to do. Run it in between optional test boilerplate.
                    pn.start_suite(k.." in "..scrfn)

                    -- Optional setup().
                    local ok, result = xpcall(test_mod.setup, debug.traceback, pn)

                    -- Run the suite.
                    ok, result = xpcall(v, debug.traceback, pn)
                    if not ok then
                        pn.UT_ERROR(result)
                        script_fail = true
                        -- goto done
                    end

                    -- Optional teardown().
                    ok, result = xpcall(test_mod.teardown, debug.traceback, pn)
                end
            end
        end
    end

    -- Finished tests.
    local end_time = os.clock()
    local dur = (end_time - start_time)

    -- Overall status.
    local pf_run = '?'
    if app_fail then pf_run = "Runner Fail"
    elseif script_fail then pf_run = "Script Fail"
    elseif pn.num_suites_failed == 0 then pf_run = "Test Pass"
    else pf_run = "Test Fail"
    end

    -- Report.
    local rep = {}
    table.insert(rep, "#------------------------------------------------------------------")
    table.insert(rep, "# Unit Test Report")
    table.insert(rep, "# Start Time: "..start_date)
    table.insert(rep, "# Duration: "..dur)
    table.insert(rep, "# Suites Run: "..pn.num_suites_run)
    table.insert(rep, "# Suites Failed: "..pn.num_suites_failed)
    table.insert(rep, "# Cases Run: "..pn.num_cases_run)
    table.insert(rep, "# Cases Failed: "..pn.num_cases_failed)
    table.insert(rep, "# Run Result: "..pf_run)
    table.insert(rep, "#------------------------------------------------------------------")
    table.insert(rep, "")

    -- Add the accumulated text.
    for _, v in ipairs(pn.result_text) do
        table.insert(rep, v)
    end

    pn.result_text = {}
    return rep
end

--------------------- start here ----------------------------------------
-- Get script args.
local scrarg = {...}

if #scrarg >= 1 then
    if scrarg[1] == 'pnut_runner' then
        -- From require. Return the module and let the client handle test scripts.
        return M
    else
        -- From command line. Process all.
        local rep = M.do_tests(...)
        for _, s in ipairs(rep) do
            print(s)
        end
    end
else
    -- From cmd line with No arg.
    error('Missing required argument')
end

-- Return the module.
return M
