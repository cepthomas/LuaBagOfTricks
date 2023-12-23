-- Generate lua interop for C, C#.

-- TODO Add table type (tableex) similar to LuaEx.cs/TableEx.cs. See structinator, 

-- Later maybe: enums, markdown, ...

local ut = require('utils')
local sx = require("stringex")


-- Capture args.
local arg = {...}

------------------------------------------------
local function usage()
    print("Usage: gen_interop.lua (-d) (-t) [-ch|-cs] [your_spec.lua] [your_outpath]")
    print("  -ch generate c and h files")
    print("  -cs generate c# file")
    print("  -d enable debugger if available")
    print("  -t use debugger terminal color")
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
local use_dbgr = false
local use_term = false

for i = 1, #arg do
    local a = arg[i]
    local valid_arg = true
    if a:sub(1, 1) == '-' then
        opt = a:sub(2)
        if opt == "d" then use_dbgr = true
        elseif opt == "t" then use_term = true
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

-- OK so far. Configure error function.
ut.config_error_handling(use_dbgr, use_term)

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
local ok, result = pcall(syntax_chunk, spec)

-- What happened?
if ok then
    -- pcall ok, examine the result.
    sep = package.config:sub(1,1)
    for k, v in pairs(result) do
        if k == "err" then
            -- Compile error, save the intermediate code.
            err_fn = sx.strjoin(sep, { out_path, "err_dcode.lua" } )
            write_output(err_fn, result.dcode)
            error("Error in TMP file " .. err_fn .. ": " .. v)
        elseif k == "dcode" then
            -- covered above.
        else
            -- Ok, save the generated code.
            if out_path:match"9$" then
                outfn = out_path..k
            else
                outfn = sx.strjoin(sep, { out_path, k } )
            end
            print('>>>', sep, out_path, k)
            write_output(outfn, v)
            print("Generated code in " .. outfn)
        end
    end
else
    -- pcall failed.
    error("pcall failed: " .. result)
end
