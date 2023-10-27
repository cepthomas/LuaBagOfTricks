-- Generate lua interop for C, C#, md.

-- FUTURE support enums?

local ut = require('utils')

-- Capture args.
local arg = {...}

------------------------------------------------
local function usage()
    print("Usage: gen_interop.lua (-d) (-t) [-ch|-md|-cs] [your_spec.lua] [your_outpath]")
    print("  -ch generate c and h files")
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
local ok, result = pcall(syntax_chunk, spec)

-- print(ok, result)
-- print(ut.dump_table_string(result))

sep = package.config:sub(1,1)


-- What happened?
if ok then
    -- pcall ok, examine the result.
    for k, v in pairs(result) do
        if k == "err" then
            -- Compile error, save the intermediate code.
            err_fn = ut.strjoin(sep, { out_path, "err_dcode.lua" } )
            write_output(err_fn, result.dcode)
            error("Error in TMP file " .. err_fn .. ": " .. v)
        elseif k == "dcode" then
            -- covered above.
        else
            -- Ok, save the generated code.
            outfn = ut.strjoin(sep, { out_path, k } )
            -- outfn = ut.strjoin(sep, { out_path, "interop_" .. spec.config.host_lib_name .. "." .. k } )
            write_output(outfn, v)
            print("Generated code in " .. outfn)
        end
    end
else
    -- pcall failed.
    error("pcall failed: " .. result)
end
