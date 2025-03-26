
-- play area for higher level constructs.

-- Main work loop called every subbeat/tick. Required.
function step(tick)
    if valid then
        -- Do something. TODO1 pattern matching like F#/C#? >>>
        -- https://stackoverflow.com/questions/37447704
        -- http://lua-users.org/wiki/SwitchStatement


        local bar, beat, sub = bt.tick_to_bt(tick)

        if bar == 1 and beat == 0 and sub == 0 then
            -- _gcheck()
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

    -- Overhead.
    api.process_step(tick)

    return 0
end





--[[

TODO1   Patterns and Switch
//public static string GetInstrumentName(int which)
string ret = which switch
{
    -1 => "NoPatch",
    >= 0 and < MAX_MIDI => _instrumentNames[which],
    _ => throw new ArgumentOutOfRangeException(nameof(which)),
};
return ret;

//IEnumerable<EventDesc> GetFilteredEvents(string patternName, List<int> channels, bool sortTime)
IEnumerable<EventDesc> descs = ((uint)patternName.Length, (uint)channels.Count) switch
{
    ( 0,  0) => AllEvents.AsEnumerable(),
    ( 0, >0) => AllEvents.Where(e => channels.Contains(e.ChannelNumber)),
    (>0,  0) => AllEvents.Where(e => patternName == e.PatternName),
    (>0, >0) => AllEvents.Where(e => patternName == e.PatternName && channels.Contains(e.ChannelNumber))
};
// Always order.
return sortTime ? descs.OrderBy(e => e.AbsoluteTime) : descs;

//
_ = key switch
{
    Keys.Key_Reset  => ProcessEvent(E.Reset, key),
    Keys.Key_Set    => ProcessEvent(E.SetCombo, key),
    Keys.Key_Power  => ProcessEvent(E.Shutdown, key),
    _               => ProcessEvent(E.DigitKeyPressed, key)
};

//
tmsec = snap switch
{
    SnapType.Coarse => MathUtils.Clamp(tmsec, MSEC_PER_SECOND, true), // second
    SnapType.Fine => MathUtils.Clamp(tmsec, MSEC_PER_SECOND / 10, true), // tenth second
    _ => tmsec, // none
};

//
string s = ArrayType switch
{
    Type it when it == typeof(int) => "",
    Type it when it == typeof(int) => "",
};



//
switch (e.Button, ControlPressed(), ShiftPressed())
{
    case (MouseButtons.None, true, false): // Zoom in/out at mouse position
        break;
    case (MouseButtons.None, false, true): // Shift left/right
        break;
}

//
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

