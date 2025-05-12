
local dbg = require("debugex")
local other = require("other_module")


-- Set configs here.
dbg.pretty_depth = 4
dbg.auto_where = 4
dbg.ansi_color = true
dbg.trace = false

-- Initialize it.
-- dbg.init(59120)
dbg.init()

dbg.print('Loading test_debugex.lua')

-- Vars.
local counter = 100

-- go.cmd
-- echo off
-- cls
-- set TERM=1
-- set LUA_PATH=?.lua;C:\Dev\Libs\LbotImpl\LBOT\?.lua;%APPDATA%\luarocks\share\lua\5.4\?.lua;;
-- set LUA_CPATH=%APPDATA%\luarocks\lib\lua\5.4\?.dll;;
-- lua test_debugex.lua


-----------------------------------------------------------------------------
local function do_command(cmd, arg)
    dbg.print('Got this command: '..cmd..'('..arg..')')
    counter = counter + 1
    local ret = 'counter => '..counter
    --dbg()
    return ret
end


-----------------------------------------------------------------------------
local function nest_2(some_arg)
    dbg.print('nest_2() was called: '..some_arg)
    return 'boom'..nil
end

-----------------------------------------------------------------------------
local function nest_1(some_arg)
    local my_table =
    {
        aa="str-pt1",
        mt={},
        bb=90901,
        alist=
        {
            "str-qwerty",
            777.888,
            temb1=
            {
                jj="str-pt8",
                b=true,
                temb2=
                {
                    num=1.517,
                    dd="string-dd"
                }
            },
            intx=5432,
            nada=nil
        },
        cc=function() end, 
        [101]='booga'
    }

    dbg.print('nest_1() was called: '..some_arg)
    dbg()
    nest_2(some_arg..'_1')
end

-----------------------------------------------------------------------------
local function lmain(some_arg)
    dbg.print('lmain() was called: '..some_arg)
    dbg()
    local sum = other.add(10, 33)
    dbg.print('other said '..sum)
    nest_1(some_arg..'_0')
end

--------------- Start here --------------------------------------------------

-- Plain function.
local res, msg = do_command('touch', 'nose')
dbg.print(string.format('do_command(): %q %s', res, msg))

-- Function that errors.
res, msg = dbg.pcall(lmain, 'green')
dbg.print(string.format('lmain(green): %q %s', res, msg))
