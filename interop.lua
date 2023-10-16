--[[
Generate lua interop for C, C++, C#, md, html?.

Supported arg and return value types: boolean integer number string tableex


TODOGEN extra include/using.
TODOGEN enums?
TODO2 clean up C:\Dev\repos\Lua\stuff\notes.txt and lua cheatsheet.


]]

local ut = require('utils')





--[[

C# flavor:
------------------
G: NAMESPACE
   CLASS_NAME

func(N):
    .HOST_FUNC_NAME
    .LUA_FUNC_NAME
    .WORK_FUNC*
    .DESCRIPTION
    .RET_TYPE
    .RET_DESCRIPTION
    calc: NUM_ARGS, NUM_RET
    arg(N):
        ARGN_TYPE
        ARGN_NAME
        REQUIRED


C flavor:
------------------

G: NAMESPACE
   CLASS_NAME

func(N):
    .HOST_FUNC_NAME
    .LUA_FUNC_NAME
    .WORK_FUNC*
    .DESCRIPTION
    .RET_TYPE
    .RET_DESCRIPTION
    calc: NUM_ARGS, NUM_RET
    arg(N):
        ARGN_TYPE
        ARGN_NAME
        REQUIRED

]]


local function gen_cs()
    print "Doing CS"


end


------------------ helpers -----------------------
-- You can solve this by adding the function to the table
-- t.insert = table.insert
-- Or using a metatable
-- setmetatable(t, {__index = {insert = table.insert}})
local op = {}
local function add_output(s) table.insert(op, s) end



------------------ Start here -------------------

-- print("")
-- print("cd:", ut.execute_capture("echo %cd%"))


-- Try this. In file `a.lua':
-- assert(loadfile("b.lua"))(10,20,30)
-- In file b.lua:
-- local a,b,c=...
-- or
-- local arg={...}
-- The arguments to b.lua are received as varargs, hence the ....





-- Get flavor.
iop = require("interop_cs")
-- C:/Dev/repos/Lua/LuaBagOfTricks/files/interop_cs.lua
-- C:/Dev/repos/Lua/LuaBagOfTricks/process_interop.lua







argsok = false

-- print("0:" .. arg[0])
-- print("1:" .. arg[1])
-- print("2:" .. arg[2])
-- print("3:" .. arg[3])

--  -ch|md|cs spec.lua outpath
if #arg == 3 then
    otype = arg[1]
    infile = arg[2]
    outpath = arg[3]

    -- Read the spec
    spec = loadfile(infile)
    if spec ~= nil then
        if otype == "-ch" then
            loadfile("b.lua"))(spec)
            gen_c()
            argsok = true
        elseif otype == "-md" then
            gen_md()
            argsok = true
        elseif otype == "-cs" then
            gen_cs()
            argsok = true
        end
    end

    if argsok == false then
        print("Bad command line - should be process_interop.lua -ch|md|cs spec.lua outpath")
    end
end



-- dofile ([filename])
-- Opens the named file and executes its content as a Lua chunk. When called without arguments, dofile executes the contens
-- of the standard input (stdin). Returns all values returned by the chunk. In case of errors, dofile propagates the error to
-- its caller. (That is, dofile does not run in protected mode.)

-- assert (v [, message])
-- Raises an error if the value of its argument v is false (i.e., nil or false); otherwise, returns all its arguments. 
-- In case of error, message is the error object; when absent, it defaults to "assertion failed!"

-- local f=loadfile"xxx"
-- f(a1,a2,a3,a4)

-- Chunks are (and have always been) vararg functions. In 5.1 you can get their
-- args as ... . If you want to create a table, add this to the chunk:
-- local arg={...}





-- add_output("Here we go")

add_output(iop.preamble)


local s = ut.strjoin('\n', op)

-- print(">>>>" .. s)

return 0



----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--[[ ------------------------------- old ----------------------------------------------

]]