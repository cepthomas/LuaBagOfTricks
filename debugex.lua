--[[

The guts of this is based on https://github.com/slembcke/debugger.lua.
https://www.slembcke.net/blog/DebuggerLua
MIT License  Copyright (c) 2024 Scott Lembcke and Howling Moon Software


TODO Don't allow step into the debugex module. Probably have to step in, see where we
     are, step out. See hook_factory. User could supply list of other modules to ignore.
TODO Break on function/line entry? Something like py tracer?

]]


-- The module.
local dbg = {}


-------------------------------------------------------------------------
----------------------------- Definitions -------------------------------
-------------------------------------------------------------------------

-- Forward refs.
local _repl
local _my_io
local _commands

-- Port number if using sockets/tcp else nil means use stdio.
local _port = nil

-- Cache.
local _last_cmd = false

-- Location of the top of the stack outside of the debugger. Adjusted by some debugger entrypoints.
local _stack_top = 0

-- The current stack frame index. Changed using the up/down commands.
local _stack_inspect_offset = 0

-- It's a cache for source code!
local _source_cache = {}

-- When error some ops are limited.
local _in_error = false

-- For ANSI formatting.
local ESC = string.char(27)

-- The stack level that cmd_* functions use to access locals or info. The structure of the code very carefully ensures this.
local CMD_STACK_LEVEL = 6

-- Category enum for writeln. The value is 256-color ansi. Customize to taste.
-- https://github.com/fidian/ansi/blob/master/images/color-codes.png.
local Cat =
{
    DEFAULT =  15, -- white
    FAINT   = 246, -- light gray
    ERROR   =   9, -- red
    FOCUS   =  11, -- yellow
    PRINT   =  40, -- green
    TRACE   = 216, -- pink
    INFO    =  39, -- blue
}
setmetatable(Cat, { __index = function(_, key) error('Invalid category: '..key) end })


-------------------------------------------------------------------------
----------------------------- IO ----------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Common IO write function.
local function write_line(str, cat)
    if cat == Cat.TRACE and not dbg.trace then return end

    -- Tweak some lines.
    if cat == Cat.ERROR then str = 'ERROR '..str end
    if cat == Cat.PRINT then str = 'SCR> '..str end

    if dbg.ansi_color then
        cat = cat or Cat.DEFAULT
        str = ESC..'[38;5;'..cat..'m'..str..ESC..'[0m'
    end
    local res, msg = _my_io.write(str..'\n')
    return res, msg
end

-------------------------------------------------------------------------
-- Common IO read function.
local function read_line(prompt)
    local res, msg = _my_io.write(prompt)
    _my_io.flush()
    res, msg = _my_io.read()
    if not res then write_line('Read error: '..msg, Cat.ERROR) end
    return res, msg
end

-------------------------------------------------------------------------
-- Local IO.
local local_io =
{
    flush = function() io.flush() end,
    write = function(str) io.write(str) end,
    read = function() return io.read() end,
}

-------------------------------------------------------------------------
-- Socket IO. https://lunarmodules.github.io/luasocket/reference.html
local _server = nil -- local
local _client = nil -- remote

local function ensure_connect()
    -- (re)connect?
    if not _client then
        local res = _server:accept()
        if res then
            _client = res
            _client:settimeout(1)
        end
    end
end

-------------------------------------------------------------------------
local socket_io =
{
    -----------------------------------
    flush = function() end, -- noop

    -----------------------------------
    write = function(str)
        local done, res, msg
        while not done do
            ensure_connect()
            -- Send payload.
            if _client then
                res, msg = _client:send(str)
                -- How did we do.
                if not res then
                    if msg == 'timeout' then
                        -- can happen, try again.
                    elseif msg == 'closed' then
                        -- can happen, try reconnect.
                        _client:close()
                        _client = nil
                    else
                        error('Fatal send error but no ui to show it: '..msg)
                    end
                else
                    done = true
                end
            end
        end

        return true
    end,

    -----------------------------------
    read = function()
        local done, res, msg, line
        while not done do
            ensure_connect()
            if _client then
                res, msg = _client:receive()
                if not res then
                    if msg == 'timeout' then
                        -- can happen, try again.
                    elseif msg == 'closed' then
                        -- can happen, try reconnect.
                        _client:close()
                        _client = nil
                    else
                        error('Fatal receive error but no ui to show it: '..msg)
                    end
                else
                    done = true
                    line = res
                end
            end
        end

        return line
    end
}


-------------------------------------------------------------------------
----------------------------- repl, hooks internals ---------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Return where we are in the stack for humans.
local function format_frame(info)
    local filename = info.source:match('^@(.*)')
    if info.what == 'Lua' then
        return string.format('%s(%d) in %s(%s)', filename, info.currentline, info.name, info.namewhat)
        -- other_module.lua(8) in field add
    else
        return '['..info.what..']'
    end
end

-------------------------------------------------------------------------
-- Return false for stack frames without source - C frames, Lua bytecode, and `loadstring` functions.
local function frame_has_line(info)
    if not info then
        write_line('frame_has_line() info is nil: '..debug.traceback(), Cat.INFO)
    end
    return info.currentline >= 0
end

-------------------------------------------------------------------------
-- Hook function factory.
local function hook_factory(repl_threshold)

    -- The hook. Step and next don't supply origin.
    return function(offset, origin)

        --  The hook is called for hook event type.
        return function(event, line_num)
            -- Skip events that don't have line information.
            local info = debug.getinfo(2)
            if not frame_has_line(info) then return end

            -- write_line(event..': '..format_frame(info), Cat.INFO)

            -- Tail calls are specifically ignored since they also will have tail returns to balance out.
            if event == 'call' then
                offset = offset + 1
            elseif event == 'return' and offset > repl_threshold then
                offset = offset - 1
            elseif event == 'line' and offset <= repl_threshold then
                origin = origin or ('line')
                _repl(origin)
            end
        end
    end
end

-------------------------------------------------------------------------
-- Predefined hooks.
local hook_step = hook_factory(1)
local hook_next = hook_factory(0)
local hook_finish = hook_factory(-1)


-------------------------------------------------------------------------
----------------------------- cmd internals -----------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Create a table of all the locally accessible variables.
-- Globals and upvalues are optional depending on caller context.
local function local_bindings(offset, include_globals, include_upvalues)
    local level = offset + _stack_inspect_offset + CMD_STACK_LEVEL
    local func = debug.getinfo(level).func
    local bindings = {}

    if include_upvalues then
        -- Retrieve the upvalues
        do local i = 1; while true do
            local name, value = debug.getupvalue(func, i)
            if not name then break end
            bindings[name] = value
            i = i + 1
        end end
    end

    -- Retrieve the locals (overwriting any upvalues)
    do local i = 1; while true do
        local name, value = debug.getlocal(level, i)
        if not name then break end
        bindings[name] = value
        i = i + 1
    end end

    -- Retrieve the varargs (works in Lua 5.2 and LuaJIT)
    local varargs = {}
    do local i = 1; while true do
        local name, value = debug.getlocal(level, -i)
        if not name then break end
        varargs[i] = value
        i = i + 1
    end end
    if #varargs > 0 then bindings['...'] = varargs end

    if include_globals then
        return setmetatable(bindings, {__index = bindings._ENV or _G})
    else
        return bindings
    end
end

-------------------------------------------------------------------------
-- Used as a __newindex metamethod to modify variables in cmd_eval().
local function mutate_bindings(_, name, value)
    local FUNC_STACK_OFFSET = 3 -- Stack depth of this function.
    local level = _stack_inspect_offset + FUNC_STACK_OFFSET + CMD_STACK_LEVEL

    -- Set a local.
    do local i = 1; repeat
        local var = debug.getlocal(level, i)
        if name == var then
            write_line('Set local variable '..name)
            return debug.setlocal(level, i, value)
        end
        i = i + 1
    until var == nil end

    -- Set an upvalue.
    local func = debug.getinfo(level).func
    do local i = 1; repeat
        local var = debug.getupvalue(func, i)
        if name == var then
            write_line('Set upvalue '..name)
            return debug.setupvalue(func, i, value)
        end
        i = i + 1
    until var == nil end

    -- Set a global.
    write_line('Set global variable '..name)
    _G[name] = value
end

-------------------------------------------------------------------------
-- Compile an expression with the given variable bindings.
local function compile_chunk(block, env, origin)

    local chunk = load(block, origin, 't', env)
    if not chunk then
        write_line('Could not compile block:', Cat.ERROR)
        write_line(block)
    end

    return chunk
end

-------------------------------------------------------------------------
-- Print info about the source.
local function where(info, context_lines)
    context_lines = context_lines or dbg.auto_where

    local source = _source_cache[info.source]
    if not source then
        source = {}
        local filename = info.source:match('^@(.*)')
        if filename then
            pcall(function() for line in io.lines(filename) do table.insert(source, line) end end)
        elseif info.source then
            for line in info.source:gmatch('([^\n]*)\n?') do table.insert(source, line) end
        end
        _source_cache[info.source] = source
    end

    write_line('In: '..format_frame(info), Cat.FOCUS)

    if source and source[info.currentline] then
        for i = info.currentline - context_lines, info.currentline + context_lines do
            local line = source[i]
            if line then
                if i == info.currentline then
                    write_line(i..' => '..line, Cat.FOCUS)
                else
                    write_line(i..'    '..line, Cat.FAINT)
                end
            end
        end
    else
        write_line('Source not available for '..info.short_src, Cat.ERROR);
    end
end

-------------------------------------------------------------------------
--- Format for humans. Returns the string.
local function pretty(obj, name, depth)

    depth = depth or dbg.pretty_depth
    local spretty = {}

    local function table_count(tbl)
        local num = 0
        for _, _ in pairs(tbl) do num = num + 1 end
        return num
    end

    -- Worker function.
    local function _worker(_obj, _name, _level)
        local sindent = string.rep('    ', _level)

        if type(_obj) == "table" then

            if (getmetatable(_obj) and getmetatable(_obj).__tostring) then
                -- tostring() can fail if there is an error in a __tostring metamethod.
                local res, val = pcall(function() return tostring(_obj) end)
                if res then
                    table.insert(spretty, string.format('%s%s:%q', sindent, _name, val))
                else
                    error(_name..' __tostring metamethod failed')
                end
            else
                table.insert(spretty, string.format('%s%s:', sindent, _name))
                -- Do contents.
                if table_count(_obj) == 0 then
                    table.insert(spretty, sindent..'    '..'<empty>')
                elseif _level >= depth then -- this stops recursion
                    table.insert(spretty, sindent..'    '..'<more>')
                else
                    for k, v in pairs(_obj) do
                        _worker(v, k, _level + 1) -- recursion!
                    end
                end
            end

        elseif type(_obj) == "string" then
            -- Dump the string so that escape sequences are printed.
            table.insert(spretty, string.format('%s%s:%q', sindent, _name, _obj))

        elseif math.type(_obj) == "integer" then
            table.insert(spretty, string.format('%s%s:%d', sindent, _name, _obj))

        elseif type(_obj) == "number" then
            table.insert(spretty, string.format('%s%s:%f', sindent, _name, _obj))

        elseif type(_obj) == "function" then
            table.insert(spretty, string.format('%s%s:<function>', sindent, _name))

        elseif type(_obj) == "boolean" then
            table.insert(spretty, string.format('%s%s:%q', sindent, _name, _obj))
        end
    end

    -- Go.
    _worker(obj, name, 0)
    local s = table.concat(spretty, '\n')
    return s
end
-------------------------------------------------------------------------
-- local function cmd_table(tbl_name, depth)
--     -- tbl What to dump.
--     -- depth How deep to go in recursion. 0 or nil means just this level.
--     depth = depth or 1
--     local level = 0
--     bindings = local_bindings(1, true, true)
--     tbl = bindings[tbl_name]

--     -- Worker function.
--     local function _dump_table(nm, tb, lvl)
--         local sindent = string.rep('    ', lvl)
--         write_line(sindent..'['..nm..']')

--         -- Do contents.
--         for k, v in pairs(tb) do
--             if type(v) == 'table' then
--                 if lvl < depth then
--                     lvl = lvl + 1
--                     _dump_table(k, v, lvl) -- recursive!
--                     lvl = lvl - 1
--                 else -- lowest
--                     write_line(string.format('%s[%s]%s=[%s]%s', sindent, type(k), tostring(k), type(v), tostring(v)))
--                 end
--             else
--                 write_line(string.format('%s[%s]%s=[%s]%s', sindent, type(k), tostring(k), type(v), tostring(v)))
--             end
--         end
--     end

--     -- Start here
--     if type(tbl) == 'table' then
--         _dump_table(tbl_name, tbl, level)
--     else
--         write_line('Not a table '..tbl_name)
--     end

--     return false
-- end


-------------------------------------------------------------------------
----------------------------- all the cmd_xxx ---------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
local function cmd_step()
    if not _in_error then
        _stack_inspect_offset = _stack_top
        return true, hook_step
    end

    write_line('Can\'t step: in error', Cat.INFO);
    return false
end

-------------------------------------------------------------------------
local function cmd_next()
    if not _in_error then
        _stack_inspect_offset = _stack_top
        return true, hook_next
    end

    write_line('Can\'t next: in error', Cat.INFO);
    return false
end

-------------------------------------------------------------------------
local function cmd_continue()
    if not _in_error then
        return true
    end

    write_line('Can\'t continue: in error', Cat.INFO);
    return false
end

-------------------------------------------------------------------------
local function cmd_finish()
    if not _in_error then
        local offset = _stack_top - _stack_inspect_offset
        _stack_inspect_offset = _stack_top
        return true, offset < 0 and hook_factory(offset - 1) or hook_finish
    end

    write_line('Can\'t finish: in error', Cat.INFO);
    return false

end

-------------------------------------------------------------------------
local function cmd_print(expr)
    local env = local_bindings(1, true, true)
    local chunk = compile_chunk('return '..expr, env, 'cmd_print')
    if chunk ~= nil then
        -- Call the chunk and collect the results.
        local results = table.pack(pcall(chunk, table.unpack(rawget(env, '...') or {})))

        -- The first result is the pcall error.
        if not results[1] then
            write_line(results[2], Cat.ERROR)
        else
            local output = ''
            for i = 2, results.n do
                output = output..(i ~= 2 and ', ' or '')..pretty(results[i], 'res'..tostring(i -1))
            end

            if output == '' then output = 'no_result' end
            write_line(expr..' => '..output)
        end
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_eval(code)
    local env = local_bindings(1, true, true)
    local mutable_env = setmetatable({},
    {
        __index = env,
        __newindex = mutate_bindings,
    })

    local chunk = compile_chunk(code, mutable_env, 'cmd_eval')
    if chunk ~= nil then
        -- Call the chunk and collect the results.
        local success, err = pcall(chunk, table.unpack(rawget(env, '...') or {}))
        if not success then
            write_line(tostring(err), Cat.ERROR)
        end
    end

    return false
end


-------------------------------------------------------------------------
local function cmd_globals()

    depth = depth or 0
    local level = 0

    local sindent = '    '
    write_line('Globals')

    for k, v in pairs(_G) do
        write_line(k..':'..type(v))
    end

    return false
end


-------------------------------------------------------------------------
local function cmd_down()
    local offset = _stack_inspect_offset
    local info

    repeat -- Find the next frame with a file.
        offset = offset + 1
        info = debug.getinfo(offset + CMD_STACK_LEVEL)
    until not info or frame_has_line(info)

    if info then
        _stack_inspect_offset = offset
        -- write_line('Inspecting frame: '..format_frame(info))
        where(info)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        write_line('Already at the bottom of the stack.')
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_up()
    local offset = _stack_inspect_offset
    local info

    repeat -- Find the next frame with a file.
        offset = offset - 1
        if offset < _stack_top then info = nil; break end
        info = debug.getinfo(offset + CMD_STACK_LEVEL)
    until frame_has_line(info)

    if info then
        _stack_inspect_offset = offset
        -- write_line('Inspecting frame: '..format_frame(info))
        where(info)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        write_line('Already at the top of the stack.')
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_inspect(offset)
    offset = _stack_top + tonumber(offset)
    local info = debug.getinfo(offset + CMD_STACK_LEVEL)
    if info then
        _stack_inspect_offset = offset
        write_line('Inspecting: '..format_frame(info), Cat.FOCUS)
    else
        write_line('Invalid stack frame index', Cat.ERROR)
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_where(context_lines)
    local info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
    where(info, tonumber(context_lines))

    return false
end

-------------------------------------------------------------------------
local function cmd_stack()
    -- write_line('Inspecting frame '..(_stack_inspect_offset - _stack_top))
    local i = 0; while true do
        local info = debug.getinfo(_stack_top + CMD_STACK_LEVEL + i)
        if not info then break end

        local is_current_frame = (i + _stack_top == _stack_inspect_offset)

        if is_current_frame then
            write_line(i..' => '..format_frame(info), Cat.FOCUS)
        else
            write_line(i..'    '..format_frame(info), Cat.FAINT)
        end

        i = i + 1
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_locals()
    local bindings = local_bindings(1, false, false)

    -- Get all the variables. Skip the debugger object itself, '(*internal)' values, and _ENV object.
    local vis = {}
    for k, v in pairs(bindings) do
        if not rawequal(v, dbg) and k ~= '_ENV' and not k:match('%(.*%)') then
            vis[k] = v
        end
    end

    write_line(pretty(vis, 'locals'), Cat.INFO)

    return false
end

-------------------------------------------------------------------------
local function cmd_quit()
    os.exit(0)
end

-------------------------------------------------------------------------
local function cmd_help()
    write_line('commands:')
    for _, v in ipairs(_commands) do write_line('  '..v[3]) end

    -- extras
    local sc = {}
    for k, v in pairs(Cat) do table.insert(sc, ESC..'[38;5;'..v..'m'..k..ESC..'[0m') end
    write_line('legend: '..table.concat(sc, ' '))

    write_line('config: port='..(_port or 'local')..' ansi_color='..tostring(dbg.ansi_color)..' trace='..tostring(dbg.trace))

    return false
end


-------------------------------------------------------------------------
----------------------------- command processor -------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
_commands =
{
    { "^c$",         cmd_continue,  'c continue execution' },
    { "^s$",         cmd_step,      's step - into functions' },
    { "^n$",         cmd_next,      'n step - over functions' },
    { "^f$",         cmd_finish,    'f step forward until exiting the current function' },
    { "^p%s+(.*)$",  cmd_print,     'p [expression] execute the expression and print the result' },
    { "^e%s+(.*)$",  cmd_eval,      'e [statement] execute the statement' },
    -- { "^t%s+(.*)$", cmd_table,     't [tbl] dump table' },
    -- { "^t%s+(.*)%s+(%d*)$", cmd_table,     't [tbl] (depth) dump table to TODO1 depth' },
    { "^u$",         cmd_up,        'u move up the stack by one frame' },
    { "^d$",         cmd_down,      'd move down the stack by one frame' },
    { "i%s*(%d+)",   cmd_inspect,   'i [index] move to and inspect a specific stack frame' },
    { "^w%s*(%d*)$", cmd_where,     'w (count) print source code around the current line' },
    { "^k$",         cmd_stack,     'k print the stack' }, -- renamed from t:cmd_trace
    { "^l$",         cmd_locals,    'l print the function arguments and locals.' }, -- upvalues now optional
    { "^g$",         cmd_globals,   'g print globals' },
    { "^h$",         cmd_help,      'h print help' },
    { "^q$",         cmd_quit,      'q halt execution' },
}

-------------------------------------------------------------------------
-- Run a command input line. Returns true if the repl should exit, optional hook
local function run_command(scmd)
    if scmd == nil then error('missing input scmd') end

    -- Re-execute the last command if return.
    if scmd == '' then scmd = _last_cmd or 'h' end

    local cmd, arg
    for _, v in ipairs(_commands) do
        if scmd:find(v[1]) then
            cmd = v[2]
            arg = scmd:match(v[1])
        end
    end

    if cmd then
        _last_cmd = scmd
        -- orig: table.unpack({...}) prevents tail call elimination so the stack frame indices are predictable.
        return table.unpack({cmd(arg)})
    else
        write_line('Invalid command', Cat.ERROR)
        return false
    end
end

-------------------------------------------------------------------------
-- The human interface repl function. origin - what triggered this.
_repl = function(origin)

    local info
    -- Skip frames without source info.
    local skip = true
    while skip do
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL - 3)
        if frame_has_line(info) then
            skip = false
        else
            _stack_inspect_offset = _stack_inspect_offset + 1
        end
    end

    write_line('Break via '..origin, Cat.FOCUS)
    where(info)

    -- Do the repl loop.
    repeat
        local success, done, hook = pcall(run_command, read_line(dbg.prompt))
        if success then
            debug.sethook(hook and hook(0), 'crl')
        else
            local msg = 'Fatal internal lua error: '..done
            write_line(msg, Cat.ERROR)
            error(msg)
        end
    until done
end

-------------------------------------------------------------------------
----------------------------- API ---------------------------------------
-------------------------------------------------------------------------


-- Default config settings. Host can override or change at runtime.
dbg.pretty_depth = 2
dbg.auto_where = 3
dbg.ansi_color = true
dbg.trace = false
dbg.prompt = '> '


-------------------------------------------------------------------------
-- Make the debugger object callable like a function.
setmetatable(dbg,
{
    __call = function(_, condition, top_offset, origin)
        if _my_io == nil then error('You forgot to call debugex.init()') end
        if condition then return end

        top_offset = top_offset or 0
        _stack_inspect_offset = top_offset
        _stack_top = top_offset
        origin = origin or 'dbg()'

        debug.sethook(hook_next(1, origin), 'crl')
        -- return
    end
})

-------------------------------------------------------------------------
-- Init the user IO.
dbg.init = function(port)
    _port = port
    _my_io = nil

    -- Maybe use socket.
    if _port ~= nil then
        local has_mod, mod = pcall(require, "socket")
        if has_mod then
            _my_io = socket_io
            -- Init the local server. Connect comes later.
            _server = mod.bind('*', _port) -- '127.0.0.1'
            _server:settimeout(1)
            local sel_ip, sel_port = _server:getsockname()
            write_line('debugex remote on '..sel_ip..':'..sel_port)
        else
            error('For remote access install socket module')
        end
    end

    -- Otherwise use local/stdio.
    if _my_io == nil then
        _my_io = local_io
        write_line('debugex running local')
    end
end

-------------------------------------------------------------------------
-- Works like plain pcall() but invokes the debugger on error().
dbg.pcall = function(func, ...)
    if _my_io == nil then error('You forgot to call debugex.init()') end

    local res, msg = xpcall(func,
        function(...)
            -- From error() - start debugger.
            _in_error = true
            dbg(false, 1, "error()")
            return ...
        end,
        ...)

    return res, msg
end

-------------------------------------------------------------------------
-- Convenience for host/applicationn to add to write stream.
function dbg.print(str)
    if _my_io == nil then error('You forgot to call debugex.init()') end
    write_line(str, Cat.PRINT)
end

-------------------------------------------------------------------------
return dbg
