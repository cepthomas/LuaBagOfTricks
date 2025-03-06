-- Generate lua interop for C, C++, C#.

local ut = require('lbot_utils')
local sx = require("stringex")


-- Capture args.
local arg = {...}

------------------------------------------------
local function usage()
    print("Usage: gen_interop.lua (-d) [-ch|-cs] [ns] [sf] [op]")
    print("  -c - generate C/H files")
    print("  -cppcli - generate C++/CLI files")
    print("  -csh - generate C# file")
    print("  -d - enable debugger if available")
    print("  sf - your_spec.lua")
    print("  op - your_outpath")
end

-- Supported flavors.
local syntaxes =
{
    c = "interop_c.lua",
    cppcli = "interop_cppcli.lua",
    csh = "interop_csh.lua"
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
local use_dbgr = false
local syntax = nil
local spec_fn = nil
local out_path = nil
local syntax_fn = nil

for i = 1, #arg do
    local parg = arg[i]
    -- print("parg:", parg)
    local valid_arg = true
    -- flags
    if parg:sub(1, 1) == '-' then
        opt = parg:sub(2)
        if opt == "d" then use_dbgr = true
        else
            syntax = opt
            syntax_fn = syntaxes[syntax]
            if not syntax_fn then valid_arg = false end
        end
    -- positional args
    elseif not spec_fn then
        spec_fn = parg
    elseif not out_path then
        out_path = parg
    else
        valid_arg = false
    end

    -- print("syntax_fn:", syntax_fn)
    -- print("spec_fn:", spec_fn)
    -- print("out_path:", out_path)

    if not valid_arg then error("Invalid command line arg: ".."["..parg.."]") end
end


if not spec_fn then error("Missing spec file") end

if not out_path then error("Missing output path") end

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
local save_error = true

-- What happened?
if ok then
    -- pcall ok, examine the result.
    sep = package.config:sub(1, 1)
    for key, val in pairs(result) do
        if key == "err" then
            if save_error then
                -- Compile error, save the intermediate code. Needs template _debug = true.
                local err_fn = sx.strjoin(sep, { out_path, "err_dcode.lua" } )
                write_output(err_fn, result.dcode)
                error("Error generating code - see "..err_fn..": "..val)
            end
        elseif key == "dcode" then
            -- Covered above.
        else -- key is out filename
            -- Ok, save the generated code.
            outfn = sx.strjoin(sep, { out_path, key } )
            write_output(outfn, val)
            print("Generated code in "..outfn)
        end
    end
else
    -- pcall failed.
    error("pcall failed: "..result)
end
