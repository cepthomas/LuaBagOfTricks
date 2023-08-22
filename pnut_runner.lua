--[[
Performs test run discovery, management, report generation.
TODO run/debug lua, exec in sublime better? close temp windows. https://github.com/slembcke/debugger.lua
TODO opts: write to file, xml format.
--]]

local pn = require("pnut")
local ut = require("utils")
local l = require("logger")


local start_time = os.clock()
local start_date = os.date()
-- Indicates an app failure.
local app_fail = false
-- Indicates an error in the user script.
local script_fail = false


-----------------------------------------------------------------------------
-- Errors not associated with test cases.
local function internal_error(msg)
    pn.UT_ERROR(msg)
    l.error(msg)
end

-----------------------------------------------------------------------------
-- Report writer.
local rf = nil
local report_fn = nil -- or from user
local function report_line(line)
    if rf ~= nil then
        rf:write(line, "\n")
    else
        l.info(line)
    end
end

-----------------------------------------------------------------------------
-- Get the cmd line args.
if #arg < 1 then
    -- log a message and exit.
    internal_error("No files supplied")
    app_fail = true
    goto done
end

-- Process each script filename.
for i = 1, #arg do
    -- load script
    local mfn = arg[i]

    local mut = require(mfn) -- loads into global
    -- or:::
    -- vv = loadfile(mfn) -- loads file
    -- mut = vv() -- executes it returning the module

    if mut == nil then
        -- log a message and exit.
        internal_error("Invalid file: " .. mfn)
        app_fail = true
        goto done
    end

    -- Dig out the test cases.
    for k, v in pairs(mut) do
        if type(v) == "function" and k:match("suite_") then
            -- Found something to do. Run it in between optional test boilerplate.
            pn.start_suite(k .. " in " .. mfn)

            local ok, result = pcall(mut["setup"], pn) -- optional
            if not ok then
                internal_error(result)
                script_fail = true
                goto done
            end

            ok, result = pcall(v, pn)
            if not ok then
                internal_error(result)
                script_fail = true
                goto done
            end

            ok, result = pcall(mut["teardown"], pn) -- optional
            if not ok then
                internal_error(result)
                script_fail = true
                goto done
            end
        end
    end
end


-----------------------------------------------------------------------------
::done::

-- Metrics.
local end_time = os.clock()
local dur = (end_time - start_time)

-- Open the report file.
if report_fn ~= nil then
    rf = io.open (report_fn, "w+")
end

-- Overall status.
if app_fail then pf_run = "Runner Fail"
elseif script_fail then pf_run = "Script Fail"
elseif suites_failed == 0 then pf_run = "Test Pass"
else pf_run = "Test Fail" end

-- Report.
report_line("#------------------------------------------------------------------")
report_line("# Unit Test Report")
report_line("# Start Time: " .. start_date)
report_line("# Duration: " .. dur)
report_line("# Suites Run: " .. pn.suites_run)
report_line("# Suites Failed: " .. pn.suites_failed)
report_line("# Cases Run: " .. pn.cases_run)
report_line("# Cases Failed: " .. pn.cases_failed)
report_line("# Run Result: " .. pf_run)
report_line("#------------------------------------------------------------------")
report_line("")

-- Add the accumulated text.
for i, v in ipairs(pn.result_text) do
    report_line(v)
end

-- Close the report file
if rf ~= nil then
    rf:close()
end
