-- Run bits of lbot code.

-- Fix up the lua path first.
package.path = './lua/?.lua;./test/lua/?.lua;'..package.path

local ut = require('lbot_utils')
local sx = require('stringex')

local current_dir = io.popen("cd"):read()
local opt = arg[1]
print(current_dir, opt)


-------------------------------------------------------------------------
local function do_colorize()
    ut.set_colorize({ ['>2<']='green', ['4<<<']='red', ['6']='bred', ['8']='yellow', ['never blue']='blue' })

    local res = {}

    for i = 1, 8 do -- inclusive
        local s = '>>>'..i..'<<<'
        clines = ut.colorize_text(s)

        for _, l in ipairs(clines) do
            print(l)
        end
    end
end


-------------------------------------------------------------------------
local function do_check_globals()
    local exp_neb = {'exp1', 'exp2', 'exp3' }
    extra, missing = ut.check_globals(exp_neb)

    print('extra:'..ut.dump_list(extra))
    print('missing:'..ut.dump_list(missing))
    -- print(ut.dump_table_string(missing, 1, 'missing'))
end


-------------------------------------------------------------------------
local function do_math()

    local function do_one(name, func)
        v = {}
        table.insert(v, name)
        for i = 0, 9 do table.insert(v, string.format("%.2f", func(i)))  end
        print(sx.strjoin(', ', v))
    end

    do_one('linear', function(i) return i / 9 end)
    do_one('exp', function(i) return math.exp(i) / 8104 end)
    do_one('log', function(i) return math.log(i) / 2.2 end)
    do_one('log 10', function(i) return math.log(i, 10) / 0.95 end)
    do_one('pow 2', function(i) return i^2 / 81 end)
    do_one('pow 3', function(i) return i^3 end)
    do_one('pow 0.67', function(i) return i^0.67 / 4.36 end)
end


-------------------------------------------------------------------------

-- do_colorize()

do_check_globals()
