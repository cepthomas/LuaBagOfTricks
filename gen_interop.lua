-- Generate lua interop for C, C#, md.

local ut = require('utils')
local dbg = require("debugger")
local have_dbg = true
-- or
-- local have_dbg, dbg = pcall(require, "debugger") -- TODO1 cleaner way
-- if not have_dbg then
--     print("You are not using debugger module!")
-- end
local function _error(msg, usage)
    if usage ~= nil then msg = msg .. "\n" .. "Usage: interop.lua -ch|md|cs your_spec.lua your_outfile" end
    if have_dbg then dbg.error(msg) else error(msg) end
end

local syntaxes =
{
    ch = "interop_c.lua",
    cs = "interop_cs.lua",
    md = "interop_md.lua"
}



local function _write_output(fn, content)
    -- output
    cf = io.open(fn, "w")
    if cf == nil then
        _error("Invalid filename: " .. fn)
    else
        cf:write(content)
        cf:close()
    end
end


if #arg ~= 3 then _error("Bad command line") end



local syn = arg[1]:sub(2)
local specfn = arg[2]
local outfn = arg[3]

-- If there are no syntactic errors, load returns the compiled chunk as a function; otherwise, it returns fail plus the error message.

local syntax_chunk, msg = loadfile(syntaxes[syn]) -- protected
if not syntax_chunk then _error("Bad syntax: " .. msg) end

-- get the spec
local spec_chunk, msg = loadfile(specfn) -- protected
if not spec_chunk then _error("Bad spec file: " .. msg) end

local status, spec = pcall(spec_chunk) -- protected
-- Its first result is the status code (a boolean), which is true if the call succeeds without errors. In such case, pcall also returns all results from the call, after this first result. In case of any error, pcall returns false plus the error object.
-- dbg()
if not status then _error("Error in spec file: " .. spec, false) end


-- execute the syntax using the spec
local status, content, code_err = pcall(syntax_chunk, spec) -- protected
if not status then _error("Error generating: " .. content, false) end

-- Always save the generated code OR the intermediate mangled code for user to review.
_write_output(outfn, content)


-- dbg()

if code_err ~= nil then
    _error("Error - see output file. " .. code_err, false)
end

-- if res == false then
--     _error("Error - other. " .. content, false)
-- end

