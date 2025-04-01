
-- Dev area.

-- _G - basic:
--   _G, _VERSION, assert, collectgarbage, dofile, error, getmetatable, ipairs, load, loadfile, next, pairs, pcall, print,
--   rawequal, rawget, rawlen, rawset, require, select, setmetatable, tonumber, tostring, type, warn, xpcall


-- TODOL want/like:
-- - using/with
-- - improved M.tern(cond, tval, fval)
-- - match see lab.lua

--------- TODOL error model?
local function ll_error(msg)

-- error (message [, level])
-- Raises an error (see §2.3) with message as the error object. This function never returns.
-- Usually, error adds some information about the error position at the beginning of the message, if the message is a string.
-- The level argument specifies how to get the error position. With level 1 (the default), the error position is where the
-- error function was called. Level 2 points the error to where the function that called error was called; and so on.
-- Passing a level 0 avoids the addition of error position information to the message.

-- warn (msg1, ···)
-- Emits a warning with a message composed by the concatenation of all its arguments (which should be strings).
-- By convention, a one-piece message starting with '@' is intended to be a control message, which is a message to the warning
-- system itself. In particular, the standard warning function in Lua recognizes the control messages "@off", to stop the emission
-- of warnings, and "@on", to (re)start the emission; it ignores unknown control messages. 

-- assert (v [, message])
-- Raises an error if the value of its argument v is false (i.e., nil or false); otherwise, returns all its arguments. In case of error,
-- message is the error object; when absent, it defaults to "assertion failed!"

end



local ut  = require('lbot_utils')
local sx  = require("stringex")

-- https://lunarmodules.github.io/Penlight/


------------------------- misc ----------------------------

-- https://lunarmodules.github.io/Penlight/libraries/pl.utils.html
-- Dependencies: pl.utils, pl.types

-- Use arbitrary lua files. require needs path fixup.
function ll_fix_lua_path(s)
    local _, _, dir = ut.get_caller_info(3)
    if not sx.contains(package.path, dir) then -- already there?
        package.path = dir..s..';'..package.path
        -- package.path = './lua/?.lua;./test/lua/?.lua;'..package.path
    end
end

-- function ll_exist(fn)
--     -- if not - error
-- end

------------------------- files ----------------------------

function ll_read_all(fn)
    f = io.open(fn, 'r')
    -- f = io.open('docs/music_defs.md', 'w')

    if f ~= nil then
        local s = f:read()
        f:close()
        return s
    else
        error('bla', 2)
    end
end

function ll_write_all(fn, s)
    f = io.open(fn, 'w')

    if f ~= nil then
        local s = f:write(s)
        f:close()
    else
        error('bla', 2)
    end
end

function ll_append(fn, s)

end




----------- TODO1 std cli interpreter ----------------------

--[[ TODOL cmd things like:
echo off
cls
set "ODIR=%cd%"
pushd ..\LBOT
set LUA_PATH="%ODIR%\?.lua";?.lua;;
lua gen_interop.lua -cppcli "%ODIR%\interop_spec.lua" "%ODIR%\Interop"
> exe fn arg1 arg2 ...
popd
call "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"
> call fn
:: Build it.
msbuild CppCli.sln /p:Configuration=Debug /t:Build -v:n
pause
]]

--[[ TODOL py things like:
    with open(log_fn, "w") as f:
        print('!!!! Totally fake !!!!', file=f)

    cmd = sys.argv[1] if len(sys.argv) >= 2 else None

    match cmd:
        case 'commit_all':
            for dirpath, dirnames, filenames in os.walk(repo_path):
                if '.git' in dirnames:
                    commit_one(dirpath, arg1)
        case _:
            log('error: Bad command line', True)
            usage()
            code = 1
]]

-- lua:  (C:\Dev\Apps\Nebulua\builder.lua)

package.path = './lua/?.lua;./test/lua/?.lua;'..package.path
local current_dir = io.popen("cd"):read()
local opt = arg[1]
local cmd = sx.strjoin(' ', { bld_exe, vrb, 'test/NebuluaTest.sln' } )
local res = ut.execute_and_capture(cmd)
_output_text(res)

-- ????
-- a dictionary
local colors = { ['Build: ']='green', ['! ']='red', ['): error ']='red', ['): warning ']='yellow' }
ut.set_colorize(colors)
local function _output_text(text)
    local ct = ut.colorize_text(text)
    for _, v in ipairs(ct) do print(v) end
end

-- a list
local exp_neb = {'luainterop', 'setup', 'step', 'receive_midi_note', 'receive_midi_controller' }
local extra, missing = ut.check_globals(exp_neb)
res = ut.dump_list(extra)

-- empty list
local elist = {}
table.insert(elist, name)
for i = 0, 9 do table.insert(elist, string.format("%.2f", func(i)))  end
print(sx.strjoin(', ', elist))

for i, v in ipairs(rep) do
    _output_text(v)
end

for k, v in pairs(rep) do
    _output_text(k, v)
end

----------- TODOL switch/pattern matching ----------------------
-- https://stackoverflow.com/questions/37447704
-- http://lua-users.org/wiki/SwitchStatement

function switch(what)
    if what == 'build_app' then
        print('aaa')
    elseif what == 'test_app' then
        print('bbb')
    else
        print('ccc')
    end
end


function pattern(bar, beat, sub)
    if bar == 1 and beat == 0 and sub == 0 then
        api.send_sequence_steps(keys_seq_steps, tick)
    end

    if beat == 0 and sub == 0 then
        api.send_sequence_steps(drums_seq_steps, tick)
        oo.do_something()
    end

    -- Every 2 bars
    if (bar == 0 or bar == 2) and beat == 0 and sub == 0 then
        api.send_sequence_steps(bass_seq_steps, tick)
    end
end


--[[ C# Patterns and Switch

string ret = which switch
{
    -1 => "NoPatch",
    >= 0 and < MAX_MIDI => _instrumentNames[which],
    _ => throw new ArgumentOutOfRangeException(nameof(which)),
};

IEnumerable<EventDesc> descs = (patternName.Length, channels.Count) switch
{
    ( 0,  0) => AllEvents.AsEnumerable(),
    ( 0, >0) => AllEvents.Where(e => channels.Contains(e.ChannelNumber)),
    (>0,  0) => AllEvents.Where(e => patternName == e.PatternName),
    (>0, >0) => AllEvents.Where(e => patternName == e.PatternName && channels.Contains(e.ChannelNumber))
};

switch (e.Button, ControlPressed(), ShiftPressed())
{
    case (MouseButtons.None, true, false): // Zoom in/out at mouse position
        break;
    case (MouseButtons.None, false, true): // Shift left/right
        break;
}

// Always order.
return sortTime ? descs.OrderBy(e => e.AbsoluteTime) : descs;

var kkk = key switch
{
    Keys.Key_Reset  => ProcessEvent(E.Reset, key),
    Keys.Key_Set    => ProcessEvent(E.SetCombo, key),
    Keys.Key_Power  => ProcessEvent(E.Shutdown, key),
    _               => ProcessEvent(E.DigitKeyPressed, key)
};

var tmsec = snap switch
{
    SnapType.Coarse => MathUtils.Clamp(tmsec, MSEC_PER_SECOND, true), // second
    SnapType.Fine => MathUtils.Clamp(tmsec, MSEC_PER_SECOND / 10, true), // tenth second
    _ => tmsec, // none
};


string Format(EventArgs e) => e switch
{
    LogArgs le => $"Log level:{le.level} msg:{le.msg}",
    SetTempoArgs te => $"SetTempo Bpm:{te.bpm}",
};

switch (ArrayType)
{
    case Type it when it == typeof(int):
        List<string> lvals = new();
        _elements.ForEach(f => lvals.Add(f.Value.ToString()!));
        ls.Add($"{sindent}{tableName}(IntArray):[ {string.Join(", ", lvals)} ]");
        break;
    case Type dt when dt == typeof(double):
        stype = "DoubleArray";
        break;
    case Type ds when ds == typeof(string):
        stype = "StringArray";
        break;
    default:
        stype = "Dictionary";
        break;
}
]]
