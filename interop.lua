--[[
Generate lua interop for C, C++, C#, md, html?.

Supported arg and return value types: boolean integer number string tableex


TODOGEN extra include/using.
TODOGEN enums?
TODO2 clean up C:\Dev\repos\Lua\stuff\notes.txt and lua cheatsheet.
]]

local ut = require('utils')
local dbg = require("debugger")
-- or
-- local available, dbg = pcall(require, "debugger")
-- if not available then
--     print("You are not using debugger module!")
-- end


local syntaxes =
{
    ch = "interop_c.lua",
    cs = "interop_cs.lua",
    md = "interop_md.lua"
}

local function _error(msg, usage)
    if usage ~= nil then msg = msg.."\n" .. "Usage: interop.lua -ch|md|cs your_spec.lua your_outfile" end
    dbg.error(msg)
end

-- print("cd:", ut.execute_capture("echo %cd%"))


if #arg ~= 3 then _error("Bad command line") end

local syntax_chunk = loadfile(syntaxes[arg[1]:sub(2)])
if syntax_chunk == nil then _error("Bad syntax "..arg[1]) end

local spec_chunk = loadfile(arg[2])
if spec_chunk == nil then _error("Bad spec file "..arg[2]) end
local res, content = pcall(spec_chunk)
if res == false then _error(content, false) end

-- execute the file
local res, spec = pcall(spec_chunk)
if res == false then _error(spec, false) end

local res, content = pcall(syntax_chunk, spec)
if res == false then _error(content, false) end

-- output
cf = io.open(out_file, "w")
if cf == nil then
    _error("Invalid filename: "..out_file)
else
    cf:write(content)
    cf:close()
end
