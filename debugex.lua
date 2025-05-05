
------------------- early wip ------------------------

-- a lot stolen from 
    -- Copyright (c) 2023 Scott Lembcke and Howling Moon Software
    -- https://github.com/slembcke/debugger.lua/blob/master/README.md
    -- https://www.slembcke.net/blog/DebuggerLua/

-- TODOD-orig Print short function arguments as part of stack location.
-- TODOD-orig Properly handle being reentrant due to coroutines.

-- TODOD You can't add breakpoints to a running program or remove them - must use dbg.run().
-- TODOD enable color explicitly?
-- TODOD something like py tracer?

-- TODOD holding tank
-- local _trace = sx.strsplit(debug.traceback(), '\n')
-- table.remove(_trace, 1)



local ut = require('lbot_utils')
local sx = require('stringex')
local tx = require("tableex")

-- Wee version differences TODOD
local unpack = unpack or table.unpack
local pack = function(...) return {n = select('#', ...), ...} end
-- local function compile_chunk(block, env)
--     if _VERSION <= 'Lua 5.1' then
--         chunk = loadstring(block, source)
--         if chunk then setfenv(chunk, env) end
--     else
--         -- The Lua 5.2 way is a bit cleaner
--         chunk = load(block, source, 't', env)
--     end
-- local function local_bindings(offset, include_globals)
--         -- In Lua 5.2, you have to get the environment table from the function's locals.
--         local env = (_VERSION <= 'Lua 5.1' and getfenv(func) or bindings._ENV)
--         return setmetatable(bindings, {__index = env or _G})



-- The module itself.
local dbg = {}


-------------------------------------------------------------------------
----------------------------- Definitions -------------------------------
-------------------------------------------------------------------------

-- Forward refs.
local repl
local _commands

-- Cache.
local _last_cmd = false

-- Location of the top of the stack outside of the debugger. Adjusted by some debugger entrypoints.
local _stack_top = 0

-- The current stack frame index. Changed using the up/down commands
local _stack_inspect_offset = 0

-- It's a cache for source code!
local _source_cache = {}

-- ANSI formatting.
local ESC = string.char(27)

-- Delimiter for message lines.
local MDEL = '\n'

-- The stack level that cmd_* functions use to access locals or info. The structure of the code very carefully ensures this.
local CMD_STACK_LEVEL = 6

-- Convenience enum.
local Color = {
    DEFAULT = 0, -- reset
    FAINT = 90, -- gray
    ERROR = 91, -- red
    WARN = 93, -- yellow
    PRINT = 92, -- green
    TRACE = 96, -- cyan
    PROMPT = 94, -- blue
    TBD = 5 -- blinking
}
setmetatable(Color, { __index = function(_, key) error('Invalid color: '..key) end })



-- TODOD need neater config setting - args or public?
local pretty_depth = 1
local auto_where = 3 -- was false
local auto_eval = false -- ??
local use_ansi_color = true
local _trace = true

-------------------------------------------------------------------------
----------------------------- Infrastructure ----------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Format for humans.
-- @param obj xxxx
-- @param name xxxx
-- @param depth xxxx
-- @return desc
local function pretty(obj, name, depth)
    if type(obj) == 'string' then
        return string.format('%q', obj)
    elseif type(obj) == 'table' then
        return tx.dump_table(obj, name, depth)
    else
        return tostring(obj)
    end
end


-------------------------------------------------------------------------
----------------------------- IO ----------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Default dbg.write function
-- @param xxx xxxx
-- @return desc
local function dbg_write(str, color)
    if color == Color.TRACE and not _trace then return end

    if use_ansi_color then
        color = color or Color.DEFAULT
        io.write(ESC..'['..color..'m'..str..ESC..'[0m')
    else -- plain
        io.write(str)
    end
end

-------------------------------------------------------------------------
--- Default dbg.writeln function
-- @param xxx xxxx
-- @return desc
local function dbg_writeln(str, color)
    dbg_write(str..MDEL, color)
end

-------------------------------------------------------------------------
--- Default dbg.read function
-- @param xxx xxxx
-- @return desc
local function dbg_read(prompt)
    dbg_write(prompt, Color.PROMPT)
    io.flush()
    return io.read()
end

-------------------------------------------------------------------------
-- Expose the debugger's IO functions. TODOD not necessary? Maybe useful for socket flavor?
-- dbg.read = dbg_read
-- dbg.write = dbg_write
-- dbg.exit = function(err) os.exit(err) end
-- dbg.pretty = pretty
-- dbg.writeln = dbg_writeln

-------------------------------------------------------------------------
--- Convenience for host to inject into write stream.
-- @param xxx xxxx
-- @return desc
function dbg.print(str)
    dbg_writeln(str, Color.PRINT)
end


-------------------------------------------------------------------------
----------------------------- repl, hooks internals ---------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Print where we are for humans.
-- @param info from this
-- @return string
local function format_frame(info)
    local filename = info.source:match('^@(.*)')
    if info.what == 'Lua' then
        return string.format('%s(%d) in %s %s', filename, info.currentline, info.namewhat, info.name)
    else
        return '['..info.what..']'
    end
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
-- Return false for stack frames without source - C frames, Lua bytecode, and `loadstring` functions.
local function frame_has_line(info)

    if not info then
        dbg_writeln('frame_has_line() !!! info is nil!!  '..debug.traceback(), Color.ERROR)
    end

    return info.currentline >= 0
end

-------------------------------------------------------------------------
--- Hook function factory.
-- @param repl_threshold xxxx
-- @return hook function
local function hook_factory(repl_threshold)

    return function(offset, reason)

        --  The hook is called for event type.
        return function(event, line_num)
            -- Skip events that don't have line information.
            if not frame_has_line(debug.getinfo(2)) then return end

            -- Tail calls are specifically ignored since they also will have tail returns to balance out.
            if event == 'call' then
                offset = offset + 1
            elseif event == 'return' and offset > repl_threshold then
                offset = offset - 1
            elseif event == 'line' and offset <= repl_threshold then
                -- step and next don't supply reason
                -- dbg_writeln(tostring(line_num), Color.TRACE)
                reason = reason or 'no-reason'
                repl(reason)
            end
        end
    end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
local hook_step = hook_factory(1)
local hook_next = hook_factory(0)
local hook_finish = hook_factory(-1)


-------------------------------------------------------------------------
----------------------------- cmd internals -----------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
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
        -- In Lua 5.2, you have to get the environment table from the function's locals.
        local env = (_VERSION <= 'Lua 5.1' and getfenv(func) or bindings._ENV)
        return setmetatable(bindings, {__index = env or _G})
    else
        return bindings
    end
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
-- Used as a __newindex metamethod to modify variables in cmd_eval().
local function mutate_bindings(_, name, value)
    local FUNC_STACK_OFFSET = 3 -- Stack depth of this function.
    local level = _stack_inspect_offset + FUNC_STACK_OFFSET + CMD_STACK_LEVEL

    -- Set a local.
    do local i = 1; repeat
        local var = debug.getlocal(level, i)
        if name == var then
            dbg_writeln('Set local variable '..name)
            return debug.setlocal(level, i, value)
        end
        i = i + 1
    until var == nil end

    -- Set an upvalue.
    local func = debug.getinfo(level).func
    do local i = 1; repeat
        local var = debug.getupvalue(func, i)
        if name == var then
            dbg_writeln('Set upvalue '..name)
            return debug.setupvalue(func, i, value)
        end
        i = i + 1
    until var == nil end

    -- Set a global.
    dbg_writeln('Set global variable '..name)
    _G[name] = value
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
-- Compile an expression with the given variable bindings.
local function compile_chunk(block, env)
    local source = 'debugex.lua REPL'
    local chunk = nil

    if _VERSION <= 'Lua 5.1' then --TODOD clean up version stuff
        chunk = loadstring(block, source)
        if chunk then setfenv(chunk, env) end
    else
        -- The Lua 5.2 way is a bit cleaner
        chunk = load(block, source, 't', env)
    end

    if not chunk then
        dbg_writeln('Could not compile block:', Color.ERROR)
        dbg_writeln(block)
    end
    return chunk
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function where(info, context_lines)
    -- dbg_writeln('where()  '..tx.dump_table(info)..' '..context_lines, Color.TRACE)
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

    dbg_writeln('=> '..format_frame(info), Color.FAINT)


    if source and source[info.currentline] then
        for i = info.currentline - context_lines, info.currentline + context_lines do
            local line = source[i]
            if line then
                if i == info.currentline then
                    dbg_writeln(i..' => '..line, Color.DEFAULT)
                else
                    dbg_writeln(i..'    '..line, Color.FAINT)
                end
            end
        end
    else
        dbg_writeln('Source not available for '..info.short_src, Color.ERROR);
    end

    return false
end

-------------------------------------------------------------------------
----------------------------- all the cmd_* -----------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_step() -- TODOD don't step into this file funcs.
    _stack_inspect_offset = _stack_top
    return true, hook_step
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_next()
    _stack_inspect_offset = _stack_top
    return true, hook_next
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_finish()
    local offset = _stack_top - _stack_inspect_offset
    _stack_inspect_offset = _stack_top
    return true, offset < 0 and hook_factory(offset - 1) or hook_finish
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_print(expr)
    local env = local_bindings(1, true)
    local chunk = compile_chunk('return '..expr, env)
    if chunk == nil then return false end

    -- Call the chunk and collect the results.
    local results = pack(pcall(chunk, unpack(rawget(env, '...') or {})))

    -- The first result is the pcall error.
    if not results[1] then
        dbg_writeln(results[2], Color.ERROR)
    else
        local output = ''
        for i = 2, results.n do
            output = output..(i ~= 2 and ', ' or '')..pretty(results[i], 'res'..tostring(i -1), pretty_depth)
        end

        if output == '' then output = 'no_result' end
        dbg_writeln(expr..' => '..output)
    end

    return false
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_eval(code)
    local env = local_bindings(1, true)
    local mutable_env = setmetatable({}, {
        __index = env,
        __newindex = mutate_bindings,
    })

    local chunk = compile_chunk(code, mutable_env)
    if chunk == nil then return false end

    -- Call the chunk and collect the results.
    local success, err = pcall(chunk, unpack(rawget(env, '...') or {}))
    if not success then
        dbg_writeln(tostring(err), Color.ERROR)
    end

    return false
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_down()
    local offset = _stack_inspect_offset
    local info

    repeat -- Find the next frame with a file.
        offset = offset + 1
        info = debug.getinfo(offset + CMD_STACK_LEVEL)
    until not info or frame_has_line(info)

    if info then
        _stack_inspect_offset = offset
        dbg_writeln('Inspecting frame: '..format_frame(info))
        where(info, auto_where)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        dbg_writeln('Already at the bottom of the stack.')
    end

    return false
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
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
        dbg_writeln('Inspecting frame: '..format_frame(info))
        where(info, auto_where)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        dbg_writeln('Already at the top of the stack.')
    end

    return false
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_inspect(offset)
    offset = _stack_top + tonumber(offset)
    local info = debug.getinfo(offset + CMD_STACK_LEVEL)
    if info then
        _stack_inspect_offset = offset
        dbg_writeln('Inspecting frame: '..format_frame(info))
    else
        dbg_writeln('Invalid stack frame index', Color.ERROR)
    end
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_where(context_lines)
    local info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
    -- dbg_writeln('cmd_where()', tonumber(context_lines), auto_where, Color.TRACE)
    return (info and where(info, tonumber(context_lines) or auto_where))
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_stack()
    dbg_writeln('Inspecting frame '..(_stack_inspect_offset - _stack_top))
    local i = 0; while true do
        local info = debug.getinfo(_stack_top + CMD_STACK_LEVEL + i)
        if not info then break end

        local is_current_frame = (i + _stack_top == _stack_inspect_offset)

        if is_current_frame then
            dbg_writeln(i..' => '..format_frame(info), Color.DEFAULT)
        else
            dbg_writeln(i..'    '..format_frame(info), Color.FAINT)
        end

        i = i + 1
    end

    return false
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_locals()
    local bindings = local_bindings(1, false)

    -- Get all the variable binding names and sort them.
    local keys = {}
    for k, _ in pairs(bindings) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, k in ipairs(keys) do
        local v = bindings[k]
        -- Skip the debugger object itself, '(*internal)' values, and Lua 5.2's _ENV object.
        if not rawequal(v, dbg) and k ~= '_ENV' and not k:match('%(.*%)') then
            dbg_writeln('  '..k..' => '..pretty(v, 'locals', pretty_depth))
        end
    end

    return false
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_continue()
    return true
end

-------------------------------------------------------------------------
--- Normal exit.
-- @param xxx xxxx
-- @return desc
local function cmd_quit()
    os.exit(0)
    return true
end

-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
local function cmd_help()
    for _, v in ipairs(_commands) do dbg_writeln('  '..v[3]) end
    return false
end

-------------------------------------------------------------------------
_commands = {
    { "^c$",         cmd_continue,  'c continue execution' },
    { "^s$",         cmd_step,      's step forward by one line (into functions)' },
    { "^n$",         cmd_next,      'n step forward by one line (skipping over functions)' },
    { "^f$",         cmd_finish,    'f step forward until exiting the current function' },
    { "^p%s+(.*)$",  cmd_print,     'p [expression] execute the expression and print the result' },
    { "^e%s+(.*)$",  cmd_eval,      'e [statement] execute the statement' },
    { "^u$",         cmd_up,        'u move up the stack by one frame' },
    { "^d$",         cmd_down,      'd move down the stack by one frame' },
    { "i%s*(%d+)",   cmd_inspect,   'i index move to and inspect a specific stack frame' },
    { "^w%s*(%d*)$", cmd_where,     'w [line count] print source code around the current line' },
    { "^t$",         cmd_stack,     't print the stack' },
    { "^l$",         cmd_locals,    'l print the function arguments, locals and upvalues.' },
    { "^h$",         cmd_help,      'h print this message' },
    { "^q$",         cmd_quit,      'q halt execution' }
}


-------------------------------------------------------------------------
----------------------------- command processor -------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Run a command line
-- @param line input string to process
-- @return true if the repl should exit, optional hook
local function run_command(line)
    if line == nil then
        error('missing input line')
    end

    -- Re-execute the last command if you press return.
    if line == '' then line = _last_cmd or 'h' end

    local cmd, arg
    for _, v in ipairs(_commands) do
        if line:find(v[1]) then
            cmd = v[2]
            arg = line:match(v[1])
        end
    end

    if cmd then
        _last_cmd = line
        -- unpack({...}) prevents tail call elimination so the stack frame indices are predictable.
        return unpack({cmd(arg)})
    elseif auto_eval then
        return unpack({cmd_eval(line)})
    else
        dbg_writeln('Invalid command '..line, Color.ERROR)
        return false
    end
end


-------------------------------------------------------------------------
--- The human interface.
-- @param reason What triggered this. Dubious usefulness, nil for some commands (s/n/?)
-- @return the repl function
-- local function repl(reason)
repl = function(reason)

    -- Skip frames without source info.
    local info
    local done = false
    while not done do
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL - 3)
        if frame_has_line(info) then
            done = true
        else
            _stack_inspect_offset = _stack_inspect_offset + 1
        end
    end

    -- orig:
    -- while not frame_has_line(debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL - 3)) do
    --     _stack_inspect_offset = _stack_inspect_offset + 1
    -- end
    -- local info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL - 3)
    -- reason = reason and ("...break via "..reason) or "not-reason"
    -- dbg_writeln(reason..format_frame(info))

    where(info, auto_where)

    -- Do the repl loop.
    repeat
        local success, done, hook = pcall(run_command, dbg_read("debugex.lua> "))
        if success then
            debug.sethook(hook and hook(0), "crl")
        else
            local msg = 'Fatal internal lua error: '..done
            dbg_writeln(msg, Color.ERROR)
            error(msg)
        end
    until done
end


-------------------------------------------------------------------------
----------------------------- api --------------------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Make the debugger object callable like a function.
-- @param xxx xxxx
-- @return desc
-- dbg = setmetatable({}, {
setmetatable(dbg, {
    __call = function(_, top_offset, source)

        dbg_writeln(string.format('__call top_offset:%d source:%s', top_offset or -1, source or 'nil'), Color.TRACE)

        top_offset = (top_offset or 0)
        _stack_inspect_offset = top_offset
        _stack_top = top_offset

        debug.sethook(hook_next(1, source or 'dbg()'), 'crl')
        -- return
    end,
})


-------------------------------------------------------------------------
--- Works like plain pcall(), but invokes the debugger on error().
-- @param xxx xxxx
-- @return desc
dbg.pcall = function(f, ...)
        dbg_writeln('XXX '..debug.traceback(), Color.TRACE)
    local ok, msg = xpcall(f,
        function(...)
            -- Start debugger.
            dbg_writeln('dbg.pcall() AAA ', Color.TRACE)

            -- dbg(1, "dbg.pcall()")

            local top_offset = 1-- (top_offset or 0)
            _stack_inspect_offset = top_offset
            _stack_top = top_offset

            debug.sethook(hook_next(1, 'dbg.pcall()'), 'crl')


            return ...
        end,
        ...)
        dbg_writeln('ZZZ '..tostring(msg), Color.TRACE)
        dbg_writeln('ZZZ '..debug.traceback(), Color.TRACE)

    return ok, msg
end

-- -- Works like pcall(), but invokes the debugger on an error.
-- function dbg.call(f, ...)
--     return xpcall(f, function(err)
--         dbg(1, "dbg.call()")
--         return err
--     end, ...)
-- end



-- Works like error(), but invokes the debugger.
function dbg.bp()
    -- level = 1
    -- dbg_writeln(COLOR_RED.."ERROR: "..COLOR_RESET..dbg.pretty(err))
    -- dbg(level, "dbg.error()")
    error()--'err', level)
end


local lua_error, lua_assert = error, assert
-- Works like error(), but invokes the debugger.
function dbg.error(err, level)
    level = level or 1
    -- dbg_writeln(COLOR_RED.."ERROR: "..COLOR_RESET..dbg.pretty(err))
    dbg(level, "dbg.error()")
    lua_error(err, level)
end


-------------------------------------------------------------------------
--- xxx
-- @param xxx xxxx
-- @return desc
-- -- Breakpoint now. Was dbg().
-- dbg.bp = function()

--     top_offset = (top_offset or 0)
--     _stack_inspect_offset = top_offset
--     _stack_top = top_offset
--     debug.sethook(hook_next(1, source or "dbg()"), "crl")
-- end

-- error(message [, level])
-- Raises an error (see §2.3) with message as the error object. This function never returns.

-- Usually, error adds some information about the error position at the beginning of the message, if the message is a string.
-- The level argument specifies how to get the error position. With level 1 (the default), the error position is 
-- where the error function was called. Level 2 points the error to where the function that called error was called; and so on.
-- Passing a level 0 avoids the addition of error position information to the message.


-- dbg = setmetatable({}, {
--     __call = function(_, condition, top_offset, source)
--         if condition then return end

--         top_offset = (top_offset or 0)
--         stack_inspect_offset = top_offset
--         stack_top = top_offset

--         debug.sethook(hook_next(1, source or "dbg()"), "crl")
--         return
--     end,
-- })


return dbg
