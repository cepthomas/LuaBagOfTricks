-- Generate lua interop for C and C#.
-- Supported types are Boolean, Integer, Number, String.
-- Later maybe: tables, enums, markdown, out pointers ...
-- TODO2 Need to check spec files for syntax. If error, err_decode.lua will contain info to parse and present to user.

local ut = require('lbot_utils')
local sx = require("stringex")


-- Capture args.
local arg = {...}

------------------------------------------------
local function usage()
    print("Usage: gen_interop.lua (-d) [-ch|-cs] [your_spec.lua] [your_outpath]")
    print("  -ch generate c and h files")
    print("  -cs generate c# file")
    print("  -d enable debugger if available")
end

-- Supported flavors.
local syntaxes =
{
    ch = "interop_ch.lua",
    cs = "interop_cs.lua"
}

-- Helper.
local function write_output(fn, content)
    -- output
    local cf = io.open(fn, "w")
    if cf == nil then
        error("Invalid filename: "..fn)
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
local use_dbgr = false

for i = 1, #arg do
    local a = arg[i]
    local valid_arg = true
    if a:sub(1, 1) == '-' then
        opt = a:sub(2)
        if opt == "d" then use_dbgr = true
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

-- print("syntax_fn:", syntax_fn)
-- print("spec_fn:", spec_fn)
-- print("out_path:", out_path)

if not spec_fn or not out_path then error("Missing output path") end

-- OK so far. Configure error function.
ut.config_debug(use_dbgr)

-- Load the specific flavor.
local syntax_chunk, msg = loadfile(syntax_fn)
if not syntax_chunk then error("Invalid syntax file: "..msg) end

-- Get the spec.
local spec_chunk, msg = loadfile(spec_fn)
if not spec_chunk then error("Invalid spec file: "..msg) end

local ok, spec = pcall(spec_chunk)

if not ok then error("Syntax in spec file: "..spec) end

-- Generate using syntax and the spec.
local ok, result = pcall(syntax_chunk, spec)
-- local ok, result = xpcall(syntax_chunk, debug.traceback, spec)

-- What happened?
if ok then
    -- pcall ok, examine the result.
    sep = package.config:sub(1, 1)
    for k, v in pairs(result) do
        if k == "err" then
            -- Compile error, save the intermediate code.
            err_fn = sx.strjoin(sep, { out_path, "err_dcode.lua" } )
            write_output(err_fn, result.dcode)
            error("Error in TMP file "..err_fn..": "..v)
        elseif k == "dcode" then
            -- covered above.
        else
            -- Ok, save the generated code.
            if out_path:match"9$" then
                outfn = out_path..k
            else
                outfn = sx.strjoin(sep, { out_path, k } )
            end
            write_output(outfn, v)
            print("Generated code in "..outfn)
        end
    end
else
    -- pcall failed.
    error("pcall failed: "..result)
end
