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

-- Supported flavors.
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
        _error("Invalid filename: " .. fn)
    else
        cf:write(content)
        cf:close()
    end
end

-- Starts here.
if #arg ~= 3 then _error("Bad command line") end

local syn = arg[1]:sub(2)
local specfn = arg[2]
local outfn = arg[3]

-- Get the specific flavor.
local syntax_chunk, msg = loadfile(syntaxes[syn]) -- protected
if not syntax_chunk then _error("Bad syntax: " .. msg) end

-- Get the spec.
local spec_chunk, msg = loadfile(specfn) -- protected
if not spec_chunk then _error("Bad spec file: " .. msg) end

local status, spec = pcall(spec_chunk) -- protected
if not status then _error("Error in spec file: " .. spec, false) end

-- Generate using syntax and the spec.
local status, content, code_err = pcall(syntax_chunk, spec) -- protected
if not status then _error("Error generating: " .. content, false) end

-- Always save the generated code OR the intermediate mangled code for user to review/debug.
_write_output(outfn, content)

-- Ehat happened?
if code_err == nil then
    print("Gen complete - see output file.", false)
else    
    _error("Error - see output file. " .. code_err, false) -- TODO1 do something cleaner with this output - point to original source?
end



-- this works:
-- >for i,p in ipairs(d:get_elements_with_name("property", true)) do
-- >datatype, basetype, isobject = gen_type(p.attr.type, p.attr.qualifier or "")
--     PROPERTY_RW($(datatype), $(p.attr.name))
-- >end -- properties



-- ERROR: "Error - see output file. [string \"TMP\"]:28: attempt to index a nil value (global 'func')\
-- stack traceback:\
-- \9[string \"TMP\"]:28: in function <[string \"TMP\"]:1>\
-- \9[C]: in function 'xpcall'\
-- \9C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\lua\\template.lua:155: in function <C:\\Dev\\repos\\Lua\\LuaBagOfTricks\\lua\\template.lua:148>\
-- \9(...tail calls...)\
-- \9interop_cs.lua:155: in main chunk\
-- \9[C]: in function 'pcall'\
-- \9gen_interop.lua:55: in main chunk\
-- \9[C]: in ?\
-- Usage: interop.lua -ch|md|cs your_spec.lua your_outfile"

-- 016 namespace "
-- 017 __R_size = __R_size + 1; __R_table[__R_size] = __tostring((config.namespace) or '')
-- 018 __R_size = __R_size + 1; __R_table[__R_size] = "\
-- 019 {\
-- 020     public partial class "
-- 021 __R_size = __R_size + 1; __R_table[__R_size] = __tostring((config.class) or '')
-- 022 __R_size = __R_size + 1; __R_table[__R_size] = "\
-- 023     {\
-- 024 >for _, func in ipairs(lua_funcs) do\
-- 025 >local klex_rt = klex_types[func.type]\
-- 026 >local cs_rt = cs_types[func.type]\
-- 027         /// <summary>Lua export function: "
-- 028 __R_size = __R_size + 1; __R_table[__R_size] = __tostring((func.description) or '')
-- 029 __R_size = __R_size + 1; __R_table[__R_size] = "</summary>\
-- 030 >for _, arg in ipairs(func.args) do\
-- 031         /// <param name=\""
-- 032 __R_size = __R_size + 1; __R_table[__R_size] = __tostring((arg.name) or '')
-- 033 __R_size = __R_size + 1; __R_table[__R_size] = "\"\">"
-- 034 __R_size = __R_size + 1; __R_table[__R_size] = __tostring((arg.description) or '')
-- 035 __R_size = __R_size + 1; __R_table[__R_size] = "</param>\
-- 036 >end\
-- 037         /// <returns>"
-- 038 __R_size = __R_size + 1; __R_table[__R_size] = __tostring((cs_rt) or '')
-- 039 __R_size = __R_size + 1; __R_table[__R_size] = " "
