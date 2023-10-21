-- Generate lua interop for C, C#, md.

local ut = require('utils')
local have_dbg, dbg = pcall(require, "debugger") -- TODO0 add global enable/disable for dbg()

local function _error(msg, usage)
    if usage ~= nil then msg = msg .. "\n" .. "Usage: interop.lua -ch|md|cs your_spec.lua your_outfile" end
    if have_dbg then dbg.error(msg) else error(msg) end
end

-- Supported flavors. TODO1 these need paths.
local syntaxes =
{
    ch = "interop_c.lua",
    cs = "interop_cs.lua",
    md = "interop_md.lua"
}

-- Helper.
local function _write_output(fn, content)
    -- output
    cf = io.open(fn, "w")
    if cf == nil then
        _error("Invalid filename: " .. fn, true)
    else
        cf:write(content)
        cf:close()
    end
end

-- Starts here.
if #arg ~= 3 then _error("Bad command line", true) end

local syn = arg[1]:sub(2)
local specfn = arg[2]
local outfn = arg[3]

-- Get the specific flavor.
local syntax_chunk, msg = loadfile(syntaxes[syn])
if not syntax_chunk then _error("Bad syntax file: " .. msg) end

-- Get the spec.
local spec_chunk, msg = loadfile(specfn)
if not spec_chunk then _error("Bad spec file: " .. msg) end

local ok, spec = pcall(spec_chunk)
if not ok then _error("Error in spec file: " .. spec) end

-- Generate using syntax and the spec.
local ok, content, code_err = pcall(syntax_chunk, spec)
if not ok then _error("Error generating: " .. content) end

-- What happened?
if code_err == nil then
    -- OK, save the generated code.
    _write_output(outfn, content)
    print("Generated code in " .. outfn)
else    
    -- Failed, save the intermediate mangled code for user to review/debug.
    err_fn = outfn .. "_err.lua"
    _write_output(err_fn, content)

-- TODO0 split code_err into strings and get up to including one with "TMP". Remove leading tabs.
-- >>>>>>>>code_err
-- attempt to index a nil value
-- stack traceback:
--         [C]: in for iterator 'for iterator'
--         [string "TMP"]:60: in function <[string "TMP"]:1>
--         [C]: in function 'xpcall'
--         .\template.lua:159: in function <.\template.lua:152>
--         (...tail calls...)
--         interop_cs.lua:176: in main chunk
--         [C]: in function 'pcall'
--         gen_interop.lua:60: in main chunk
--         [C]: in ?

    dbg()
    _error("Error - see output file " .. err_fn .. ": " .. code_err)
end
