
local ut = require("lbot_utils")
local lt = require("lbot_types")
local sx = require("stringex")
local tx = require('tableex')


-- Needs env TERM=1.
local dbg = require("debugger")

local counter = 100

print('Loading test_debugger.lua')


-----------------------------------------------------------------------------
-- fake script here:


-----------------------------------------------------------------------------
local function do_command(cmd, arg)
    print('Got this command: '..cmd..'('..arg..')')
    local ret = 'counter => '..counter
    -- dbg()
    counter = counter + 1
    return ret
end

-----------------------------------------------------------------------------
local function nest2(some_arg)
    print('nest2() was called: '..some_arg)
    return 'boom'..nil
end

-----------------------------------------------------------------------------
local function nest1(some_arg)
    print('nest1() was called: '..some_arg)
    dbg()
    return nest2(some_arg..'1')
end

-----------------------------------------------------------------------------
local function boom(some_arg)
    print('boom() was called: '..some_arg)
    return nest1(some_arg..'0')
end

--------------- Start here --------------------------------------------------

print('do_command():', do_command('touch', 'nose'))

print('boom():', boom('green'))
