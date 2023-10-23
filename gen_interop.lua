-- Generate lua interop for C, C#, md.

-- TODO support enums?

local ut = require('utils')

local arg={...}
-- print(ut.dump_table_string(arg))

------------------------------------------------
local function usage()
    print("Usage: gen_interop.lua (-d) (-t) [-ch|-md|-cs] [your_spec.lua] [your_outfile.xyz]")
    print("  -ch generate d and h files")
    print("  -cs generate c# file")
    print("  -md generate markdown file")
    print("  -d enable debugger if available")
    print("  -t use debugger terminal color")
end

-- Supported flavors.
local syntaxes =
{
    ch = "interop_ch.lua",
    cs = "interop_cs.lua",
    md = "interop_md.lua"
}

-- Helper.
local function write_output(fn, content)
    -- output
    local cf = io.open(fn, "w")
    if cf == nil then
        error("Invalid filename: " .. fn)
    else
        cf:write(content)
        cf:close()
    end
end

-- Gather args.
local syntaxfn = nil
local specfn = nil
local outfn = nil
local dbgr = false
local term = false

for i = 1, #arg do
    local a = arg[i]
    local valid_arg = true
    if a:sub(1, 1) == '-' then
        opt = a:sub(2)
        if opt == "d" then dbgr = true
        elseif opt == "t" then term = true
        else
            syntaxfn = syntaxes[opt]
            if not syntaxfn then valid_arg = false end
        end
    elseif not specfn then
        specfn = a
    elseif not outfn then
        outfn = a
    else
        valid_arg = false
    end

    if not valid_arg then error("Invalid command line arg: "..a) end
end
if not specfn or not outfn then error("Missing file name") end

-- OK so far. Use lbot extras?
local have_lbot, lbot = pcall(require, "lbot")
if have_lbot then
    lbot.config_error_handling(dbgr, term)
end

-- Get the specific flavor.
local syntax_chunk, msg = loadfile(syntaxfn)
if not syntax_chunk then error("Invalid syntax file: " .. msg) end

-- Get the spec.
local spec_chunk, msg = loadfile(specfn)
if not spec_chunk then error("Invalid spec file: " .. msg) end

local ok, spec = pcall(spec_chunk)
-- print(ut.dump_table_string(spec))
if not ok then error("Syntax in spec file: " .. spec) end

-- Generate using syntax and the spec.
local ok, content, code_err = pcall(syntax_chunk, spec)
if not ok then error("Error generating: " .. content) end

-- What happened?
if code_err == nil then
    -- OK, save the generated code.
    write_output(outfn, content)
    print("Generated code in " .. outfn)
else
    -- Failed, save the intermediate mangled code for user to review/debug.
    local err_fn = outfn .. "_err.lua"
    write_output(err_fn, content)
    error("Error in TMP file " .. err_fn .. ": " .. code_err)
end
