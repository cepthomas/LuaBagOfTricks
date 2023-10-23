-- Generate lua interop for C, C#, md.

-- TODO0 run with environment/cli inside ST. Don't set TERM. TERM env from config?
-- TODO2 support enums?

local ut = require('utils')


--------------- TODO1 debugger and error stuff relocate for gp use.
local enb_debugger = false
local have_debugger = false
local enb_term = false

local function _configErrorHandling()
    if enb_debugger then
        have_debugger, dbg = pcall(require, "debugger")
        if not have_debugger then print(dbg) end
    end

    -- print(enb_debugger, have_debugger, enb_term)

    if have_debugger and enb_term then
        dbg.enable_color()
    end

    -- Make a global stub just in case.
    if not have_debugger then
        function dbg() end
    end

    dbg()
end

local function _error(msg)
    if have_debugger and enb_debugger then
        dbg.error(msg)
    else
        error(msg)
    end
end

local function _usage()
    print("Usage: gen_interop.lua (-d) (-t) [-ch|-md|-cs] [your_spec.lua] [your_outfile.xyz]")
    print("  -ch generate d and h files")
    print("  -cs generate c# file")
    print("  -md generate markdown file")
    print("  -d enable debugger if available")
    print("  -t use debugger terminal color")
end

------------------------------------------------

-- Supported flavors. TODO0 these need explicit paths.
local syntaxes =
{
    ch = "interop_ch.lua",
    cs = "interop_cs.lua",
    md = "interop_md.lua"
}

-- Helper.
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

---------------------- Real app work starts here -----------------------------------

-- Gather args.
local syntaxfn = nil
local specfn = nil
local outfn = nil

for _, a in ipairs(arg) do
    local valid_arg = true
    if a:sub(1, 1) == '-' then
        opt = a:sub(2)
        if opt == "d" then enb_debugger = true
        elseif opt == "t" then enb_term = true
        else
            syntaxfn = syntaxes[opt]
            if syntaxfn then valid_arg = true end
        end
    elseif not specfn then
        specfn = a
    elseif not outfn then
        outfn = a
    else
        valid_arg = false
    end

    if not valid_arg then _error("Invalid command line arg: "..a) end
end
if not specfn or not outfn then _error("Missing file name") end

-- OK so far.
_configErrorHandling()

-- Get the specific flavor.
local syntax_chunk, msg = loadfile(syntaxfn)
if not syntax_chunk then _error("Invalid syntax file: " .. msg) end

-- Get the spec.
local spec_chunk, msg = loadfile(specfn)
if not spec_chunk then _error("Invalid spec file: " .. msg) end

local ok, spec = pcall(spec_chunk)
if not ok then _error("Syntax in spec file: " .. spec) end

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
    _error("Error in TMP file " .. err_fn .. ": " .. code_err)
end
