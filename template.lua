--[[
A slightly modified version of the template module from https://github.com/lunarmodules/Penlight.
  - Removed dependencies on other penlight modules - it's standalone.
  - do_escape(s) snipped from pl.utils. 
  - Doesn't support nested expansions like: l.$(to_funcs[$(func.ret.type)]).

Docs from original
Originally by [Ricki Lake](http://lua-users.org/wiki/SlightlyLessSimpleLuaPreprocessor)

There are two rules:
    * lines starting with # are Lua
    * otherwise, `$(expr)` is the result of evaluating `expr`

Example:
    #  for i = 1,3 do
       $(i) Hello, Word!
    #  end
    ===>
    1 Hello, Word!
    2 Hello, Word!
    3 Hello, Word!

Other escape characters can be used, when the defaults conflict with the output language.
    > for _,n in pairs{'one','two','three'} do
    static int l_${n} (luaState *state);
    > end

See  @{03-strings.md.Another_Style_of_Template|the Guide}.
]]

--- Escape any Lua 'magic' characters in a string.
-- @param s The input string
local function do_escape(s)
    -- utils.assert_string(1, s)
    return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]', '%%%1'))
end


local append, format, strsub, strfind, strgsub = table.insert, string.format, string.sub, string.find, string.gsub

local APPENDER = "\n__R_size = __R_size + 1; __R_table[__R_size] = "

local function parseDollarParen(pieces, chunk, exec_pat, newline)
    local s = 1
    for term, executed, e in chunk:gmatch(exec_pat) do
        executed = '('..strsub(executed, 2, -2)..')'
        append(pieces, APPENDER..format("%q", strsub(chunk, s, term - 1)))
        append(pieces, APPENDER..format("__tostring(%s or '')", executed))
        s = e
    end

    local r
    if newline then
        r = format("%q", strgsub(strsub(chunk, s), "\n", ""))
    else
        r = format("%q", strsub(chunk, s))
    end
    if r ~= '""' then
        append(pieces, APPENDER..r)
    end
end

local function parseHashLines(chunk, inline_escape, brackets, esc, newline)
    -- Escape special characters to avoid invalid expressions.
    inline_escape = do_escape(inline_escape)
    esc = do_escape(esc)

    local exec_pat = "()"..inline_escape.."(%b"..brackets..")()"

    local esc_pat = esc.."+([^\n]*\n?)"
    local esc_pat1, esc_pat2 = "^"..esc_pat, "\n"..esc_pat
    local  pieces, s = {"return function()\nlocal __R_size, __R_table, __tostring = 0, {}, __tostring", n = 1}, 1
    while true do
        local _, e, lua = strfind(chunk, esc_pat1, s)
        if not e then
            local ss
            ss, e, lua = strfind(chunk, esc_pat2, s)
            parseDollarParen(pieces, strsub(chunk, s, ss), exec_pat, newline)
            if not e then break end
        end
        if strsub(lua, -1, -1) == "\n" then lua = strsub(lua, 1, -2) end
        append(pieces, "\n"..lua)
        s = e + 1
    end
    append(pieces, "\nreturn __R_table\nend")

    -- Check for a special case where there is nothing to template, but it's just a single static string.
    local short = false
    if (#pieces == 3) and (pieces[2]:find(APPENDER, 1, true) == 1) then
        pieces = { "return " .. pieces[2]:sub(#APPENDER + 1, -1) }
        short = true
    end
    -- if short == true, the generated function will not return a table of strings, but a single string.
    return table.concat(pieces), short
end

local template = {}

--- Expand the template using the specified environment.
-- This function will compile and render the template. For more performant
-- recurring usage use the two step approach by using `compile` and `ct:render`.
-- There are six special fields in the environment table `env`
--
--   * `_parent`: continue looking up in this table (e.g. `_parent=_G`).
--   * `_brackets`: bracket pair that wraps inline Lua expressions,  default is '()'.
--   * `_escape`: character marking Lua lines, default is '#'
--   * `_inline_escape`: character marking inline Lua expression, default is '$'.
--   * `_chunk_name`: chunk name for loaded templates, used if there
--     is an error in Lua code. Default is 'TMP'.
--   * `_debug`: if truthy, the generated code will be printed upon a render error
--
-- @param str the template string
-- @param [opt] env the environment
-- @return rendered_template,nil,source_code or nil,error,source_code. (source_code if debug option)
function template.substitute(str, env)
    env = env or {}

    local t, err, code = template.compile(str, {
        chunk_name = rawget(env, "_chunk_name"),
        escape = rawget(env, "_escape"),
        inline_escape = rawget(env, "_inline_escape"),
        inline_brackets = rawget(env, "_brackets"),
        newline = nil,
        debug = rawget(env, "_debug")
    })

    if not t then return t, err, code end

    return t:render(env, rawget(env, "_parent"), rawget(env, "_debug"))
end

--- Executes the previously compiled template and renders it.
-- @param[opt] env the environment.
-- @param[opt] parent continue looking up in this table (e.g. `parent=_G`).
-- @return rendered_template,nil,source_code or nil,error,source_code. (source_code if debug option)
-- @usage
-- local ct, err = template.compile(my_template)
-- local rendered, err = ct:render(my_env, parent)
local render = function(self, env, parent)
    env = env or {}
    if parent then  -- parent is a bit silly, but for backward compatibility retained
        setmetatable(env, {__index = parent})
    end
    setmetatable(self.env, {__index = env})

    local res, out = xpcall(self.fn, debug.traceback)
    if not res then
        return nil, out, self.code
    end
    return table.concat(out), nil, self.code
end

--- Compiles the template.
-- Returns an object that can repeatedly be rendered without parsing/compiling
-- the template again.
-- The options passed in the `opts` table support the following options:
--
--   * `chunk_name`: chunk name for loaded templates, used if there
--     is an error in Lua code. Default is 'TMP'.
--   * `escape`: character marking Lua lines, default is '#'
--   * `inline_escape`: character marking inline Lua expression, default is '$'.
--   * `inline_brackets`: bracket pair that wraps inline Lua expressions, default is '()'.
--   * `newline`: string to replace newline characters, default is `nil` (not replacing newlines).
--   * `debug`: if truthy, the generated source code will be retained within the compiled template object, default is `nil`.
--
-- @param str the template string
-- @param[opt] opts the compilation options to use
-- @return template_object or nil,error,source_code. (source_code if debug option)
-- @usage
-- local ct, err = template.compile(my_template)
-- local rendered, err = ct:render(my_env, parent)
function template.compile(str, opts)
    opts = opts or {}
    local chunk_name = opts.chunk_name or 'TMP'
    local escape = opts.escape or '#'
    local inline_escape = opts.inline_escape or '$'
    local inline_brackets = opts.inline_brackets or '()'

    local code, short = parseHashLines(str, inline_escape, inline_brackets, escape, opts.newline)
    local env = { __tostring = tostring }
    -- was local fn, err = utils.load(code, chunk_name, 't', env)
    local fn, err = load(code, chunk_name, 't', env)
    if not fn then return nil, err, code end

    if short then
        -- The template returns a single constant string, let's optimize for that.
        local constant_string = fn()
        return {
            fn = fn(),
            env = env,
            render = function(self) -- additional params can be ignored
                -- Skip the metatable magic and error handling in the render function above for this special case.
                return constant_string, nil, self.code
            end,
            code = opts.debug and code or nil,
        }
    end

    return {
        fn = fn(),
        env = env,
        render = render,
        code = opts.debug and code or nil,
    }
end

return template
