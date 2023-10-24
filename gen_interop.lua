-- Generate lua interop for C, C#, md.

-- TODO support enums?

local ut = require('utils')

-- Capture args.
local arg = {...}
-- print(ut.dump_table_string(arg))

------------------------------------------------
local function usage()
    print("Usage: gen_interop.lua (-d) (-t) [-ch|-md|-cs] [your_spec.lua] [your_outpath]")
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
local syntax_fn = nil
local syntax = nil
local spec_fn = nil
local out_path = nil
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
            syntax = opt
            syntax_fn = syntaxes[syntax]
            if not syntax_fn then valid_arg = false end
        end
    elseif not spec_fn then
        spec_fn = a
    elseif not out_path then
        out_path = a
    else
        valid_arg = false
    end

    if not valid_arg then error("Invalid command line arg: "..a) end
end
if not spec_fn or not out_path then error("Missing output path") end

-- OK so far. Use lbot extras?
local have_lbot, lbot = pcall(require, "lbot")
if have_lbot then
    lbot.config_error_handling(dbgr, term)
end

-- Get the specific flavor.
local syntax_chunk, msg = loadfile(syntax_fn)
if not syntax_chunk then error("Invalid syntax file: " .. msg) end

-- Get the spec.
local spec_chunk, msg = loadfile(spec_fn)
if not spec_chunk then error("Invalid spec file: " .. msg) end

local ok, spec = pcall(spec_chunk)
-- print(ut.dump_table_string(spec))
if not ok then error("Syntax in spec file: " .. spec) end

-- Generate using syntax and the spec.
local ok, content, code_err = pcall(syntax_chunk, spec)
if not ok then error("Error generating: " .. content) end

-- What happened?
if code_err == nil then
    -- OK, save the generated code. ?? 2 files ??
    outfn = ut.strjoin('/', { out_path, spec.config.host_lib_name .. "Interop." .. syntax } )
    write_output(outfn, content)
    print("Generated code in " .. outfn)
else
    -- Failed, save the intermediate mangled code for user to review/debug.
    err_fn = ut.strjoin('/', { out_path, spec.config.host_lib_name .. "_err.lua" } )
    write_output(err_fn, content)
    error("Error in TMP file " .. err_fn .. ": " .. code_err)
end
