
local ut = require('utils')
local tmpl = require('pl.template')
local dbg = require("debugger")

local arg = {...}
local spec = arg[1]

-- p = ut.dump_table(arg, 0)
-- print(ut.strjoin('\n', p))


-- LuaEx functions.
local push_funcs = 
{
    boolean = "PushBoolean",
    integer = "PushInteger",
    number = "PushNumber",
    string ="PushString",
    tableex = "PushTableEx"
}

local is_funcs = 
{
    boolean = "IsBoolean",
    integer = "IsInteger",
    number = "IsNumber",
    string ="IsString",
    tableex = "IsTableEx"
}

local to_funcs = 
{
    boolean = "ToBoolean",
    integer = "ToInteger",
    number = "ToNumber",
    string ="ToString",
    tableex = "ToTableEx"
}


local ttt = 
[[
///// Warning - this is a file generated by gen_interop.lua, do not edit. /////

using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;
|for _, us in ipairs(config.add_using) do
using $(us);
|end

namespace $(config.namespace)
{
    public partial class $(config.class)
    {
        |for _, func in ipairs(lua_funcs) do
        /// <summary>Lua export function: $(func.description)</summary>
        |for _, arg in ipairs(func.args) do
        /// <param name="$(arg.name)">$(arg.description)</param>
        |end
        /// <returns>$(func.ret.type) $(func.ret.description)></returns>

        public $(func.ret.type)? $(func.host_func_name)(
        |for _, arg in ipairs(func.args) do 
         $(arg.type) $(arg.name),
        |end
        )
        {
            $(func.ret.type)? ret = null;
            // Get function.
            LuaType ltype = _l.GetGlobal($(func.lua_func_name));
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: $(func.lua_func_name)")); return null; )

            // Push arguments
            |for _, arg in ipairs(func.args) do 
            //$(arg.type) $(arg.name);
            _l.$(push_funcs[$(arg.type)])($(arg.name));
            |end

            // Do the actual call.
            LuaStatus lstat = _l.DoCall($(#func.args), 1);
            if (lstat >= LuaStatus.ErrRun) { ErrorHandler(new SyntaxException("DoCall() failed")); return null; )

            // Get the results from the stack.
            ret = _l.$(to_funcs[$(func.ret.type)])(-1);
            if (ret is null) { ErrorHandler(new SyntaxException("Return value is not a $(func.ret.type)")); return null; )
            _l.Pop(1);

            return ret;
        )
        |end -- funcs

        |for _, func in ipairs(host_funcs) do
        /// <summary>Host export function: $(func.description)</summary>
        |for _, arg in ipairs(func.args) do
        /// <param name="$(arg.name)">$(arg.description)</param>
        |end
        /// <returns>$(func.ret.type) {func.ret.description)></returns>
        static int $(func.host_func_name)(IntPtr p)
        {
            Lua? l = Lua.FromIntPtr(p);

            // Get arguments
            |for _, arg in ipairs(func.args) do
            $(arg.type)? $(arg.name) = null;
            if (l!.$(is_funcs[$(func.ret.type)])(1)) { $(arg.name) = l.$(to_funcs[$(func.ret.type)])(1); )
            else { ErrorHandler(new SyntaxException($"Bad arg type for {$(arg.name))")); return 0; )
            |end

            // Do the work.
            $(func.ret.type) ret = $(func.work_func;)(
            |for _, arg in ipairs(func.args) do 
            $(arg.name),
            |end
            );

            // Return result (one).
            l.$(push_funcs[$(func.ret.type)])(ret);

            return 1;
        )
        |end -- funcs

        //------------------ Infrastructure ----------------------//
        readonly LuaRegister[] _libFuncs = new LuaRegister[]
        {
            // ALL collected.

            |for _, func in ipairs(host_funcs) do
            new LuaRegister($(func.lua_func_name), $(func.host_func_name)),
            |end

            new LuaRegister(null, null)
        };

        int InteropOpen(IntPtr p)
        {
            var l = Lua.FromIntPtr(p)!;
            l.NewLib(_libFuncs);
            return 1;
        }

        void InteropLoad()
        {
            _l.RequireF($(config.lib_name), InteropOpen, true);
        }
    }
}
]]

-- Make the output file.
-- @return `rendered template + nil + source_code`, or `nil + error + source_code`.
-- The last return value (`source_code`) is only returned if the debug option is used.

local tmpl_env = { _escape='|', _parent=_G, _debug=true, config=spec.config, lua_funcs=spec.lua_export_funcs, host_funcs=spec.host_export_funcs }

dbg()

rendered, err, source = tmpl.substitute(ttt, tmpl_env)

print(source)

if err == nil then
    return rendered
else
    error(err)
end



-- add_output(preamble)

-- for _, func in ipairs{spec.lua_export_funcs} do
--     -- lua_func_name
--     -- host_func_name
--     -- description

--     for _, arg in ipairs{func.args} do
--         -- name
--         -- type
--         -- description


--     end

--     local ret = func.ret
--     -- type
--     -- description


-- end

-- add_output(postamble)



-- return ut.strjoin('\n', output)
