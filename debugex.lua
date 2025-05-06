--[[

A lot stolen from :
https://github.com/slembcke/debugger.lua/blob/master/README.md
https://www.slembcke.net/blog/DebuggerLua/

Plain lua 5.2+ only.

TODOD-orig Print short function arguments as part of stack location.
TODOD-orig Properly handle being reentrant due to coroutines.
TODOD You can't add breakpoints to a running program or remove them - must use dbg.run().
TODOD something like py tracer?


]]

-- local ut = require('lbot_utils')
-- local sx = require('stringex')
-- local tx = require("tableex")


-------------------------------------------------------------------------
-- Expose the debugger's IO functions. Probably not necessary? Maybe useful for socket flavor?
-- dbg.read = dbg_read
-- dbg.write = dbg_write
-- dbg.exit = function(err) os.exit(err) end
-- dbg.pretty = pretty
-- dbg.writeln = dbg_writeln



-- The module.
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

-- Convenience enum for writeln.
local Color = {
    DEFAULT = 15, -- white
    FAINT   = 246, -- light gray
    ERROR   = 9, -- red
    FOCUS   = 11, -- yellow
    PRINT   = 40, -- green
    TRACE   = 216, -- pink
    TABLE   = 39, -- blue
    TBD     = 05  -- blinking
}
setmetatable(Color, { __index = function(_, key) error('Invalid color: '..key) end })

-- local Color = {
--     DEFAULT = 00, -- reset
--     FAINT   = 90, -- light gray
--     ERROR   = 91, -- red
--     FOCUS   = 93, -- yellow
--     PRINT   = 92, -- green
--     TRACE   = 96, -- cyan
--     TABLE   = 94, -- blue
--     TBD     = 05  -- blinking
-- }


-- Config settings. TODOD some?
dbg.pretty_depth = 3
dbg.auto_where = 3 -- was false
dbg.ansi_color = true
dbg.trace = true

-------------------------------------------------------------------------
----------------------------- Infrastructure ----------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--- Format for humans. Returns the string.
local function pretty(obj, name, depth)

    depth = depth or dbg.pretty_depth
    local res = {}

    local function table_count(tbl)
        local num = 0
        for _, _ in pairs(tbl) do num = num + 1 end
        return num
    end

    -- Worker function. object
    local function _worker(_obj, _name, _level)
        local sindent = string.rep('    ', _level)

        if type(_obj) == "table" then

            if (getmetatable(_obj) and getmetatable(_obj).__tostring) then
                -- tostring() can fail if there is an error in a __tostring metamethod.
                local ok, val = pcall(function() return tostring(_obj) end)
                if ok then
                    table.insert(res, string.format('%s%s:%q', sindent, _name, val))
                else
                    error(_name..' __tostring metamethod failed')
                end
            else
                table.insert(res, string.format('%s%s:', sindent, _name))
                -- Do contents.
                if table_count(_obj) == 0 then
                    table.insert(res, sindent..'    '..'<empty>')
                elseif _level >= depth then -- this stops recursion
                    table.insert(res, sindent..'    '..'<more>')
                else
                    for k, v in pairs(_obj) do
                        _worker(v, k, _level + 1) -- recursion!
                    end
                end
            end

        elseif type(_obj) == "string" then
            -- Dump the string so that escape sequences are printed.
            table.insert(res, string.format('%s%s:%q', sindent, _name, _obj))

        elseif math.type(_obj) == "integer" then
            table.insert(res, string.format('%s%s:%d', sindent, _name, _obj))

        elseif type(_obj) == "number" then
            table.insert(res, string.format('%s%s:%f', sindent, _name, _obj))

        elseif type(_obj) == "function" then
            table.insert(res, string.format('%s%s:<function>', sindent, _name))

        elseif type(_obj) == "boolean" then
            table.insert(res, string.format('%s%s:%q', sindent, _name, _obj))
        end
    end

    -- Go.
    _worker(obj, name, 0)
    local s = table.concat(res, '\n')
    return s
end


-------------------------------------------------------------------------
----------------------------- IO ----------------------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
-- Default dbg.write function
local function dbg_write(str, color)
    if color == Color.TRACE and not dbg.trace then return end

    if dbg.ansi_color then
        color = color or Color.DEFAULT
        io.write(ESC..'[38;5;'..color..'m'..str..ESC..'[0m')
    else -- plain
        io.write(str)
    end
end

-------------------------------------------------------------------------
-- Default dbg.writeln function
local function dbg_writeln(str, color)
    dbg_write(str..MDEL, color)
end

-------------------------------------------------------------------------
-- Default dbg.read function
local function dbg_read(prompt)
    dbg_write(prompt)
    io.flush()
    return io.read()
end

-------------------------------------------------------------------------
-- Convenience for host to inject into write stream.
function dbg.print(str)
    dbg_writeln(str, Color.PRINT)
end


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
        dbg_writeln('frame_has_line() info is nil'..debug.traceback(), Color.ERROR)
    end

    return info.currentline >= 0
end

-------------------------------------------------------------------------
-- Hook function factory.
local function hook_factory(repl_threshold)

    return function(offset, origin)

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
                -- Step and next don't supply this.
                origin = origin or ('line:'..line_num)
                repl(origin)
            end
        end
    end
end

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
-- Compile an expression with the given variable bindings.
local function compile_chunk(block, env, origin)

    local chunk = load(block, origin, 't', env)

    if not chunk then
        dbg_writeln('Could not compile block:', Color.ERROR)
        dbg_writeln(block)
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

    dbg_writeln('=> '..format_frame(info), Color.FOCUS)

    if source and source[info.currentline] then
        for i = info.currentline - context_lines, info.currentline + context_lines do
            local line = source[i]
            if line then
                if i == info.currentline then
                    dbg_writeln(i..' => '..line, Color.FOCUS)
                else
                    dbg_writeln(i..'    '..line, Color.FAINT)
                end
            end
        end
    else
        dbg_writeln('Source not available for '..info.short_src, Color.ERROR);
    end
end

-------------------------------------------------------------------------
----------------------------- all the cmd_* -----------------------------
-------------------------------------------------------------------------

-------------------------------------------------------------------------
local function cmd_step() -- TODOD don't step into dbg() funcs. See cmd_locals().
    _stack_inspect_offset = _stack_top

    return true, hook_step
end

-------------------------------------------------------------------------
local function cmd_next()
    _stack_inspect_offset = _stack_top

    return true, hook_next
end

-------------------------------------------------------------------------
local function cmd_finish()
    local offset = _stack_top - _stack_inspect_offset
    _stack_inspect_offset = _stack_top

    return true, offset < 0 and hook_factory(offset - 1) or hook_finish
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
            dbg_writeln(results[2], Color.ERROR)
        else
            local output = ''
            for i = 2, results.n do
                output = output..(i ~= 2 and ', ' or '')..pretty(results[i], 'res'..tostring(i -1))
            end

            if output == '' then output = 'no_result' end
            dbg_writeln(expr..' => '..output)
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
            dbg_writeln(tostring(err), Color.ERROR)
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
        dbg_writeln('Inspecting frame: '..format_frame(info))
        where(info)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        dbg_writeln('Already at the bottom of the stack.')
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
        dbg_writeln('Inspecting frame: '..format_frame(info))
        where(info)
    else
        info = debug.getinfo(_stack_inspect_offset + CMD_STACK_LEVEL)
        dbg_writeln('Already at the top of the stack.')
    end

    return false
end

-------------------------------------------------------------------------
local function cmd_inspect(offset)
    offset = _stack_top + tonumber(offset)
    local info = debug.getinfo(offset + CMD_STACK_LEVEL)
    if info then
        _stack_inspect_offset = offset
        dbg_writeln('Inspecting frame: '..format_frame(info))
    else
        dbg_writeln('Invalid stack frame index', Color.ERROR)
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
    dbg_writeln('Inspecting frame '..(_stack_inspect_offset - _stack_top))
    local i = 0; while true do
        local info = debug.getinfo(_stack_top + CMD_STACK_LEVEL + i)
        if not info then break end

        local is_current_frame = (i + _stack_top == _stack_inspect_offset)

        if is_current_frame then
            dbg_writeln(i..' => '..format_frame(info), Color.FOCUS)
        else
            dbg_writeln(i..'    '..format_frame(info), Color.FAINT)
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

    dbg_writeln(pretty(vis, 'locals'), Color.TABLE)

    return false
end

-- -------------------------------------------------------------------------
-- local function cmd_locals_XXX()
--     local bindings = local_bindings(1, false)

--     -- Get all the variable binding names and sort them.
--     local keys = {}
--     for k, _ in pairs(bindings) do
--         table.insert(keys, k)
--     end
--     table.sort(keys)

--     for _, k in ipairs(keys) do
--         local v = bindings[k]
--         -- Skip the debugger object itself, '(*internal)' values, and Lua 5.2's _ENV object.
--         if not rawequal(v, dbg) and k ~= '_ENV' and not k:match('%(.*%)') then
--             -- dbg_writeln(pretty(v, 'locals'))
--             dbg_writeln('  '..k..' => '..pretty(v, 'locals'))
--         end
--     end

--     return false
-- end

-------------------------------------------------------------------------
local function cmd_continue()
    return true
end

-------------------------------------------------------------------------
local function cmd_quit()
    os.exit(0)
end

-------------------------------------------------------------------------
local function cmd_help()
    for _, v in ipairs(_commands) do dbg_writeln('  '..v[3]) end

    return false
end


-------------------------------------------------------------------------
----------------------------- command processor -------------------------
-------------------------------------------------------------------------

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
-- Run a command input line. Returns true if the repl should exit, optional hook
local function run_command(scmd)
    if scmd == nil then
        error('missing input scmd')
    end

    -- Re-execute the last command if you press return.
    if scmd == '' then
        scmd = _last_cmd or 'h'
    end

    local cmd, arg
    for _, v in ipairs(_commands) do
        if scmd:find(v[1]) then
            cmd = v[2]
            arg = scmd:match(v[1])
        end
    end

    if cmd then
        _last_cmd = scmd
        -- table.unpack({...}) prevents tail call elimination so the stack frame indices are predictable.
        return table.unpack({cmd(arg)})
    else
        dbg_writeln('Invalid command', Color.ERROR)
        return false
    end
end


-------------------------------------------------------------------------
-- The human interface repl function.
repl = function(origin)
    -- origin - What triggered this.

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

    -- local info = debug.getinfo(stack_inspect_offset + CMD_STACK_LEVEL - 3)
    -- reason = reason and (COLOR_YELLOW.."break via "..COLOR_RED..reason..GREEN_CARET) or ""
    -- dbg_writeln(reason..format_stack_frame_info(info))

    dbg_writeln('Break via '..origin, Color.FOCUS)

    where(info)

    -- Do the repl loop.
    repeat
        local success, done, hook = pcall(run_command, dbg_read('>>> '))

        -- print('repl:', success, done, hook)

        if success then
            debug.sethook(hook and hook(0), 'crl')
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
-- Make the debugger object callable like a function.
-- dbg = setmetatable({}, {
setmetatable(dbg, {
    __call = function(_, top_offset, origin)

        dbg_writeln(string.format('__call top_offset:%d origin:%s', top_offset or -1, origin or 'nil'), Color.TRACE)

        top_offset = (top_offset or 0)
        _stack_inspect_offset = top_offset
        _stack_top = top_offset

        debug.sethook(hook_next(1, origin or 'dbg()'), 'crl')
        -- return
    end,
})


-------------------------------------------------------------------------
-- Works like plain pcall(), but invokes the debugger on error().
dbg.pcall = function(func, ...)

    local ok, msg = xpcall(func,
        function(...)
            -- Start debugger.
            dbg(1, "error()") -- TODOD disable s/n/c, allow stack nav and l/w/etc
            -- TODOD or...
            -- local top_offset = 1-- (top_offset or 0)
            -- _stack_inspect_offset = top_offset
            -- _stack_top = top_offset
            -- debug.sethook(hook_next(1, 'error()'), 'crl')

            return ...
        end,
        ...)

    return ok, msg
end

-- -- Works like pcall(), but invokes the debugger on an error.
-- function dbg.call(f, ...)
--     return xpcall(f, function(err)
--         dbg(1, "dbg.call()")
--         return err
--     end, ...)
-- end

-- -- Works like error(), but invokes the debugger.
-- function dbg.bp()
--     -- level = 1
--     -- dbg_writeln(COLOR_RED.."ERROR: "..COLOR_RESET..dbg.pretty(err))
--     -- dbg(level, "dbg.error()")
--     error()--'err', level)
-- end


-- local lua_error, lua_assert = error, assert
-- -- Works like error(), but invokes the debugger.
-- function dbg.error(err, level)
--     level = level or 1
--     -- dbg_writeln(COLOR_RED.."ERROR: "..COLOR_RESET..dbg.pretty(err))
--     dbg(level, "dbg.error()")
--     lua_error(err, level)
-- end

-- -- Breakpoint now. Was dbg().
-- dbg.bp = function()

--     top_offset = (top_offset or 0)
--     _stack_inspect_offset = top_offset
--     _stack_top = top_offset
--     debug.sethook(hook_next(1, source or "dbg()"), "crl")
-- end


return dbg
