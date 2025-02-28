-- Generate C# specific interop code. Requires KeraLuaEx to compile.

local ut = require('lbot_utils')
local tmpl = require('template')

-- Get specification.
local args = {...}
local spec = args[1]


--------------------------------------------------------------------------------
---------------------------- Gen C# file ---------------------------------------
--------------------------------------------------------------------------------
local tmpl_src =
[[
///// Warning - this file is created by gen_interop.lua, do not edit. /////

>local ut = require('lbot_utils')
>local sx = require("stringex")

using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;
>if config.add_refs ~= nil then
>for _, us in ipairs(config.add_refs) do
using $(us);
>end
>end

namespace $(config.namespace)
{
    public partial class $(config.class)
    {
        #region Functions exported from lua for execution by host
>for _, func in ipairs(script_funcs) do
>local klex_ret_type = klex_types[func.ret.type]
>local cs_ret_type = cs_types[func.ret.type]
        /// <summary>Lua export function: $(func.description or "")</summary>
>for _, arg in ipairs(func.args or {}) do
        /// <param name="$(arg.name)">$(arg.description or "")</param>
>end -- func.args
        /// <returns>$(cs_ret_type) $(func.ret.description or "")></returns>
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, cs_types[arg.type] .. " " .. arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
        public $(cs_ret_type)? $(func.host_func_name)($(sargs))
        {
            int numArgs = 0;
            int numRet = 1;

            // Get function.
            LuaType ltype = _l.GetGlobal("$(func.lua_func_name)");
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: $(func.lua_func_name)")); return null; }

            // Push arguments.
>for _, arg in ipairs(func.args or {}) do
>local klex_arg_type = klex_types[arg.type]
            _l.Push$(klex_arg_type)($(arg.name));
            numArgs++;
>end -- func.args

            // Do the actual call.
            LuaStatus lstat = _l.DoCall(numArgs, numRet);
            if (lstat >= LuaStatus.ErrRun) { ErrorHandler(new SyntaxException("DoCall() failed")); return null; }

            // Get the results from the stack.
            $(cs_ret_type)? ret = _l.To$(klex_ret_type)(-1);
            if (ret is null) { ErrorHandler(new SyntaxException("Return value is not a $(cs_ret_type)")); return null; }
            _l.Pop(1);
            return ret;
        }

>end -- script_funcs
        #endregion

        #region Functions exported from host for execution by lua
>for _, func in ipairs(host_funcs) do
>local klex_ret_type = klex_types[func.ret.type]
>local cs_ret_type = cs_types[func.ret.type]
        /// <summary>Host export function: $(func.description or "")
>for _, arg in ipairs(func.args or {}) do
        /// Lua arg: "$(arg.name)">$(arg.description or "")
>end -- func.args
        /// Lua return: $(cs_ret_type) $(func.ret.description or "")>
        /// </summary>
        /// <param name="p">Internal lua state</param>
        /// <returns>Number of lua return values></returns>
        int $(func.host_func_name)(IntPtr p)
        {
            Lua l = Lua.FromIntPtr(p)!;

            // Get arguments
>for i, arg in ipairs(func.args or {}) do
>local klex_arg_type = klex_types[arg.type]
>local cs_arg_type = cs_types[arg.type]
            $(cs_arg_type)? $(arg.name) = null;
            if (l.Is$(klex_arg_type)($(i))) { $(arg.name) = l.To$(klex_arg_type)($(i)); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {$(arg.name)}")); return 0; }
>end -- func.args

            // Do the work. One result.
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
            $(cs_ret_type) ret = $(func.host_func_name)Work($(sargs));
            l.Push$(klex_ret_type)(ret);
            return 1;
        }

>end -- host_funcs
        #endregion

        #region Infrastructure
        // Bind functions to static instance.
        static $(config.class)? _instance;
        // Bound functions.
>for _, func in ipairs(host_funcs) do
        static LuaFunction? _$(func.host_func_name);
>end -- host_funcs
        readonly List<LuaRegister> _libFuncs = new();

        int OpenInterop(IntPtr p)
        {
            var l = Lua.FromIntPtr(p)!;
            l.NewLib(_libFuncs.ToArray());
            return 1;
        }

        void LoadInterop()
        {
            _instance = this;
>for _, func in ipairs(host_funcs) do
            _$(func.host_func_name) = _instance!.$(func.host_func_name);
            _libFuncs.Add(new LuaRegister("$(func.lua_func_name)", _$(func.host_func_name)));
>end -- host_funcs

            _libFuncs.Add(new LuaRegister(null, null));
            _l.RequireF("$(config.lua_lib_name)", OpenInterop, true);
        }
        #endregion
    }
}
]]


-- Type name conversions.
local klex_types = { B = "Boolean", I = "Integer", N = "Number", S = "String", T = "TableEx" }
local cs_types = { B = "bool", I = "int", N = "double", S = "string", T = "TableEx" }

-- Make the output content. 
local tmpl_env =
{
    _parent=_G,
    _escape='>',
    _debug=true,
    config=spec.config,
    script_funcs=spec.script_funcs,
    host_funcs=spec.host_funcs,
    klex_types=klex_types,
    cs_types=cs_types
}

local ret = {} -- { "gensrc1.cs"=rendered, "gensrc2.cs"=rendered, err, dcode }
print('Generating cs file')

local rendered, err, dcode = tmpl.substitute(tmpl_src, tmpl_env)

if not err then -- ok
    ret["LuaInterop.cs"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

return ret
