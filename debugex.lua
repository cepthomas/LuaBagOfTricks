--[[

Put in doc:
A lot of this stolen from :
https://github.com/slembcke/debugger.lua
https://www.slembcke.net/blog/DebuggerLua

Plain lua 5.2+ only.

You can't add breakpoints to a running program or remove them - must use dbg.run().

orig Properly handle being reentrant due to coroutines.

]]

-- TODOD something like py tracer?

-- The module.
local dbg = {}


-------------------------------------------------------------------------
----------------------------- Definitions -------------------------------
-------------------------------------------------------------------------

-- Forward refs.
local repl
local my_io
local socket_io
local _commands

-- Port number if using sockets else local cli.
local _port = nil

-- Cache.
local _last_cmd = false

-- Location of the top of the stack outside of the debugger. Adjusted by some debugger entrypoints.
local _stack_top = 0

-- The current stack frame index. Changed using the up/down commands
local _stack_inspect_offset = 0

-- It's a cache for source code!
local _source_cache = {}

-- When error some ops are limited.
local _in_error = false

-- ANSI formatting.
local ESC = string.char(27)

-- Delimiter for message lines.
local MDEL = '\n'

-- The stack level that cmd_* functions use to access locals or info. The structure of the code very carefully ensures this.
local CMD_STACK_LEVEL = 6

-- Category enum for writeln. The value is 256-color ansi. https://github.com/fidian/ansi/blob/master/images/color-codes.png.
local Cat = {
    DEFAULT =  15, -- white
    FAINT   = 246, -- light gray
    ERROR   =   9, -- red
    FOCUS   =  11, -- yellow
    PRINT   =  40, -- green
    TRACE   = 216, -- pink
    INFO    =  39, -- blue
    TBD     =  05  -- blinking
}
setmetatable(Cat, { __index = function(_, key) error('Invalid color: '..key) end })


-------------------------------------------------------------------------
----------------------------- IO ----------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Common client write function.
local function client_write(str, color)
    if color == Cat.TRACE and not dbg.trace then return end

    if dbg.ansi_color then
        color = color or Cat.DEFAULT
        str = ESC..'[38;5;'..color..'m'..str..ESC..'[0m'..MDEL
    end
    local res, msg = my_io.write(str)
    return res, msg
end

-------------------------------------------------------------------------
-- Common client read function.
local function client_read(prompt)
    -- client_write(prompt)
    local res, msg = my_io.write(prompt)
    my_io.flush()
    res, msg = my_io.read()
    if not res then client_write('Read error: '..msg, Cat.ERROR) end
    return res, msg
end

-------------------------------------------------------------------------
-- Socket IO. https://lunarmodules.github.io/luasocket/reference.html
socket_io = {
    server = nil, -- local
    client = nil, -- remote
    flush = function() end, -- Noop.
}

-------------------------------------------------------------------------
-- Write whole line. This blocks until the client picks it up.
function socket_io.write(str)
    local done = false
    while not done do
        if socket_io.client == nil then
            socket_io.client = socket_io.server:accept()
        end

        local res, msg = socket_io.client:send(str..'\n')

        if not res then
            if msg == 'closed' or msg == 'timeout' then
                -- can happen, try open next time.
                socket_io.client:close()
                socket_io.client = nil
            else
                error('Fatal send error but no ui to show it: '..msg)
            end
        else
            done = true
        end
    end

    return true
end


-------------------------------------------------------------------------
-- Blocking read line. This blocks until the client sends something.
function socket_io.read()
    local done = false
    local line
    while not done do
        if socket_io.client == nil then
            socket_io.client = socket_io.server:accept()
        end

        local res, msg = socket_io.client:receive()

        if not res then
            if msg == 'closed' or msg == 'timeout' then
                -- can happen, try open next time.
                socket_io.client:close()
                socket_io.client = nil
            else
                error('Fatal receive error but no ui to show it: '..msg)
            end
        else
            done = true
            line = res
        end
    end

    return line
end

-------------------------------------------------------------------------


-------------------------------------------------------------------------
----------------------------- repl, hooks internals ---------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Return where we are in the stack for humans.
local function format_frame(info)
    local filename = info.source:match('^@(.*)')
    if info.what == 'Lua' then
        return string.format('%s(%d) in %s %s', filename, info.currentline, info.namewhat, info.name)
    else
        return '['..info.what..']'
    end
end

-------------------------------------------------------------------------
-- Return false for stack frames without source - C frames, Lua bytecode, and `loadstring` functions.
local function frame_has_line(info)
    if not info then
        client_write('frame_has_line() info is nil'..debug.traceback(), Cat.ERROR)
    end
    return info.currentline >= 0
end

-------------------------------------------------------------------------
-- Hook function factory. Not sure what 'repl_threshold' means.
local function hook_factory(repl_threshold)

    -- The hook. Step/next don't supply origin.
    return function(offset, origin)

        --  The hook is called for hook event type.
        return function(event, line_num)
            -- Skip events that don't have line information.
            local info = debug.getinfo(2)
            if not frame_has_line(info) then return end

            -- Tail calls are specifically ignored since they also will have tail returns to balance out.
            if event == 'call' then
                offset = offset + 1
            elseif event == 'return' and offset > repl_threshold then
                offset = offset - 1
            elseif event == 'line' and offset <= repl_threshold then
                -- print('hook', offset, repl_threshold, origin)
                origin = origin or ('line')
                repl(origin)
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
-- Globals are not included when running the locals command, but are when running the print command.
local function local_bindings(offset, include_globals)
    local level = offset + _stack_inspect_offset + CMD_STACK_LEVEL
    local func = debug.getinfo(level).func
    local bindings = {}

    -- Retrieve the upvalues
    do local i = 1; while true do
        local name, value = debug.getupvalue(func, i)
        if not name then break end
        bindings[name] = value
        i = i + 1
    end end

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
            client_write('Set local variable '..name)
            return debug.setlocal(level, i, value)
        end
        i = i + 1
    until var == nil end

    -- Set an upvalue.
    local func = debug.getinfo(level).func
    do local i = 1; repeat
        local var = debug.getupvalue(func, i)
        if name == var then
            client_write('Set upvalue '..name)
            return debug.setupvalue(func, i, value)
        end
        i = i + 1
    until var == nil end

    -- Set a global.
    client_write('Set global variable '..name)
    _G[name] = value
end

-------------------------------------------------------------------------
-- Compile an expression with the given variable bindings.
local function compile_chunk(block, env, origin)

    local chunk = load(block, origin, 't', env)

    if not chunk then
        client_write('Could not compile block:', Cat.ERROR)
        client_write(block)
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

    client_write('Frame: '..format_frame(info), Cat.FOCUS)

    if source and source[info.currentline] then
        for i = info.currentline - context_lines, info.currentline + context_lines do
            local line = source[i]
            if line then
                if i == info.currentline then
                    client_write(i..' => '..line, Cat.FOCUS)
                else
                    client_write(i..'    '..line, Cat.FAINT)
                end
            end
        end
    else
        client_write('Source not available for '..info.short_src, Cat.ERROR);
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
----------------------------- all the cmd_s -----------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
local function cmd_step() -- TODOD don't step into this module. Or builtin, required, ???
    if not _in_error then
        _stack_inspect_offset = _stack_top
        return true, hook_step
    end

    client_write('Can\'t step: in error', Cat.INFO);
    return false
end

-------------------------------------------------------------------------
local function cmd_next()
    if not _in_error then
        _stack_inspect_offset = _stack_top
        return true, hook_next
    end

    client_write('Can\'t next: in error', Cat.INFO);
    return false
end

-------------------------------------------------------------------------
local function cmd_continue()
    if not _in_error then
        return true
    end

    client_write('Can\'t continue: in error', Cat.INFO);
    return false
end

-------------------------------------------------------------------------
local function cmd_finish()
    if not _in_error then
        local offset = _stack_top - _stack_inspect_offset
        _stack_inspect_offset = _stack_top
        return true, offset < 0 and hook_factory(offset - 1) or hook_finish
    end

    client_write('Can\'t finish: in error', Cat.INFO);
    return false

end

-------------------------------------------------------------------------
local function cmd_print(expr)
    local env = local_bindings(1, true)
    local chunk = compile_chunk('return '..expr, env, 'cmd_print')
    if chunk ~= nil then
        -- Call the chunk and collect the results.
        local results = table.pack(pcall(chunk, table.unpack(rawget(env, '...') or {})))

        -- The first result is the pcall error.
        if not results[1] then
            client_write(results[2], Cat.ERROR)
        else
            local output = ''
            for i = 2, results.n do
                output = output..(i ~= 2 and ', ' or '')..pretty(results[i], 'res'..tostring(i -1))
            end

            if output == '' then output = 'no_result' end
            client_write(expr..' => '..output)
        end
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_eval(code)
    local env = local_bindings(1, true)
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
            client_write(tostring(err), Cat.ERROR)
        end
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
        client_write('Inspecting frame: '..format_frame(info))
        where(info)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        client_write('Already at the bottom of the stack.')
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
        client_write('Inspecting frame: '..format_frame(info))
        where(info)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        client_write('Already at the top of the stack.')
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_inspect(offset)
    offset = _stack_top + tonumber(offset)
    local info = debug.getinfo(offset + CMD_STACK_LEVEL)
    if info then
        _stack_inspect_offset = offset
        client_write('Inspecting frame: '..format_frame(info))
    else
        client_write('Invalid stack frame index', Cat.ERROR)
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
    client_write('Inspecting frame '..(_stack_inspect_offset - _stack_top))
    local i = 0; while true do
        local info = debug.getinfo(_stack_top + CMD_STACK_LEVEL + i)
        if not info then break end

        local is_current_frame = (i + _stack_top == _stack_inspect_offset)

        if is_current_frame then
            client_write(i..' => '..format_frame(info), Cat.FOCUS)
        else
            client_write(i..'    '..format_frame(info), Cat.FAINT)
        end

        i = i + 1
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_locals()
    local bindings = local_bindings(1, false)

    -- Get all the variables. Skip the debugger object itself, '(*internal)' values, and _ENV object.
    local vis = {}
    for k, v in pairs(bindings) do
        if not rawequal(v, dbg) and k ~= '_ENV' and not k:match('%(.*%)') then
            vis[k] = v
        end
    end

    client_write(pretty(vis, 'locals'), Cat.INFO)

    return false
end

-------------------------------------------------------------------------
local function cmd_quit()
    os.exit(0)
end

-------------------------------------------------------------------------
local function cmd_help()
    for _, v in ipairs(_commands) do client_write('  '..v[3]) end

    return false
end


-------------------------------------------------------------------------
----------------------------- command processor -------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
_commands = {
    { "^c$",         cmd_continue,  'c continue execution' },
    { "^s$",         cmd_step,      's step - into functions' },
    { "^n$",         cmd_next,      'n step - over functions' },
    { "^f$",         cmd_finish,    'f step forward until exiting the current function' },
    { "^p%s+(.*)$",  cmd_print,     'p [expression] execute the expression and print the result' },
    { "^e%s+(.*)$",  cmd_eval,      'e [statement] execute the statement' },
    { "^u$",         cmd_up,        'u move up the stack by one frame' },
    { "^d$",         cmd_down,      'd move down the stack by one frame' },
    { "i%s*(%d+)",   cmd_inspect,   'i [index] move to and inspect a specific stack frame' },
    { "^w%s*(%d*)$", cmd_where,     'w (count) print source code around the current line' },
    { "^t$",         cmd_stack,     't print the stack' },
    { "^l$",         cmd_locals,    'l print the function arguments, locals and upvalues.' },
    { "^h$",         cmd_help,      'h print help' },
    { "^q$",         cmd_quit,      'q halt execution' }
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
        client_write('Invalid command', Cat.ERROR)
        return false
    end
end

-------------------------------------------------------------------------
-- The human interface repl function. origin - what triggered this.
repl = function(origin)

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

    client_write('Break via '..origin, Cat.FOCUS)
    where(info)

    -- Do the repl loop.
    repeat
        local success, done, hook = pcall(run_command, client_read('>>> '))
        if success then
            debug.sethook(hook and hook(0), 'crl')
        else
            local msg = 'Fatal internal lua error: '..done
            client_write(msg, Cat.ERROR)
            error(msg)
        end
    until done
end

-------------------------------------------------------------------------
----------------------------- API ---------------------------------------
-------------------------------------------------------------------------


-- Default config settings. Host can override or change at runtime.
dbg.pretty_depth = 1
dbg.auto_where = 3
dbg.ansi_color = true
dbg.trace = false


-------------------------------------------------------------------------
-- Make the debugger object callable like a function.
setmetatable(dbg,
{
    __call = function(_, top_offset, origin)
        if my_io == nil then error('ERROR: debugex.init() has not been called') end

        top_offset = top_offset or 0
        _stack_inspect_offset = top_offset
        _stack_top = top_offset

        -- From dbg() - start debugger.
        debug.sethook(hook_next(1, origin or 'dbg()'), 'crl')
        -- return
    end
})

-------------------------------------------------------------------------
-- Init the user IO.
dbg.init = function(port)
    _port = port
    my_io = nil
    -- Maybe use socket.
    if _port ~= nil then
        local has_mod, mod = pcall(require, "socket")
print(port, has_mod, mod)
        if has_mod then
            client_write('Using socket')
            my_io = socket_io
            -- Init the local _server. Connect comes later.
            socket_io.server = mod.bind('*', _port) -- '127.0.0.1'
            -- local ip, port = _server:getsockname()
            socket_io.server:settimeout(nil) -- block forever
        end
    end

    -- Otherwise use local/stdio.
    if my_io == nil then
        my_io = require('io')
        client_write('Using stdio')
    end
end

-------------------------------------------------------------------------
-- Works like plain pcall() but invokes the debugger on error().
dbg.pcall = function(func, ...)
    if my_io == nil then error('ERROR: debugex.init() has not been called') end

    local res, msg = xpcall(func,
        function(...)
            -- From error() - start debugger.
            _in_error = true
            dbg(1, "error()")
            return ...
        end,
        ...)

    return res, msg
end

-------------------------------------------------------------------------
-- Convenience for host/applicationn to add to write stream.
function dbg.print(str)
    if my_io == nil then error('ERROR: debugex.init() has not been called') end
    client_write(str, Cat.PRINT)
end

-------------------------------------------------------------------------
return dbg
