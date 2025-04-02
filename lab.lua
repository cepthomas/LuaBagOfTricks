
--[[
! organize modules/globals: https://www.lua.org/pil/15.4.html

add init.lua file? see http://www.playwithlua.com/?p=64


_G stuff to add?
---------------------
- basic: _G, _VERSION, assert, collectgarbage, dofile, error, getmetatable, ipairs, load, loadfile, next, pairs, pcall, print,
    rawequal, rawget, rawlen, rawset, require, select, setmetatable, tonumber, tostring, type, warn, xpcall
- modules: coroutine, debug, io, math, os, package, string, table, utf8, 
- metamethods: __add, __band, __bnot, __bor, __bxor, __call, __close, __concat, __div, __eq, __gc, __idiv, __index, 
    __le, __len, __lt, __metatable, __mod, __mode, __mul, __name, __newindex, __pairs, __pow, __shl, __shr, __sub,
    __tostring, __unm



? args can be
  - utils.on_error 'quit'
  - utils.on_error('quit')
  - utils.on_error'quit'  ??


-- pl import/require
require 'pl' -- calls Penlight\lua\pl\init.lua
utils.import 'pl.func' -- take a table/module and 'inject' it into the local namespace.
local ops = require 'pl.operator' -- normal import
local List = require 'pl.List' -- class
local append, concat = table.insert, table.concat -- aliases
local optable = ops.optable -- alias

]]



-----------  ----------------------

--[[

TODOL scripting - For things like C:\Dev\Apps\Nebulua\builder.lua

>>> cmd things like:
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



>>> py things like:
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



--[[ 

- TODOL switch/pattern matching ----------------------
- https://stackoverflow.com/questions/37447704
- http://lua-users.org/wiki/SwitchStatement

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


>>> C# Patterns and Switch

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
