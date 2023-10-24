-- Generate C# specific interop code. Requires KeraLuaEx to compile.

local ut = require('utils')
local tmpl = require('template')
-- local dbg = require("debugger")

-- Get specification.
local args = {...}
local spec = args[1]


local t =
[[
///// Warning - this file is created by gen_interop.lua, do not edit. /////
>local ut = require('utils')
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;
>for _, us in ipairs(config.add_refs) do
using $(us);
>end

namespace $(config.namespace)
{
    public partial class $(config.host_lib_name)
    {
        #region Functions exported from lua for execution by host
>for _, func in ipairs(lua_funcs) do
>local klex_ret_type = klex_types[func.ret.type] or "???"
>local cs_ret_type = cs_types[func.ret.type] or "???"
        /// <summary>Lua export function: $(func.description or "")</summary>
>for _, arg in ipairs(func.args or {}) do
        /// <param name="$(arg.name)">$(arg.description or "")</param>
>end -- func.args
        /// <returns>$(cs_ret_type) $(func.ret.description or "")></returns>
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, cs_types[arg.type] .. " " .. arg.name)
>end -- func.args
>sargs = ut.strjoin(", ", arg_specs)
        public $(cs_ret_type)? $(func.host_func_name)($(sargs))
        {
            int numArgs = 0;
            int numRet = 1;

            // Get function.
            LuaType ltype = _l.GetGlobal("$(func.lua_func_name)");
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: $(func.lua_func_name)")); return null; }

            // Push arguments
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
>end -- lua_funcs

        #endregion

        #region Functions exported from host for execution by lua
>for _, func in ipairs(host_funcs) do
>local klex_ret_type = klex_types[func.ret.type] or "???"
>local cs_ret_type = cs_types[func.ret.type] or "???"
        /// <summary>Host export function: $(func.description or "")
>for _, arg in ipairs(func.args or {}) do
        /// Lua arg: "$(arg.name)">$(arg.description or "")
>end -- func.args
        /// Lua return: $(cs_ret_type) $(func.ret.description or "")>
        /// </summary>
        /// <param name="p">Internal lua state</param>
        /// <returns>Number of lua return values></returns>
        static int $(func.host_func_name)(IntPtr p)
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
>sargs = ut.strjoin(", ", arg_specs)
            $(cs_ret_type) ret = $(func.host_func_name)Work($(sargs));
            l.Push$(klex_ret_type)(ret);
            return 1;
        }
>end -- host_funcs

        #endregion

        #region Infrastructure
        readonly LuaRegister[] _libFuncs = new LuaRegister[]
        {
            // ALL collected.
>for _, func in ipairs(host_funcs) do
            new LuaRegister("$(func.lua_func_name)", $(func.host_func_name)),
>end -- host_funcs
            new LuaRegister(null, null)
        };

        int OpenInterop(IntPtr p)
        {
            var l = Lua.FromIntPtr(p)!;
            l.NewLib(_libFuncs);
            return 1;
        }

        public void LoadInterop()
        {
            _l.RequireF("$(config.lib_name)", OpenInterop, true);
        }
        #endregion
    }
}
]]

-- Type name conversions.
local klex_types = { B = "Boolean", I = "Integer", N = "Number", S ="String", T = "TableEx"}
local cs_types = { B = "bool", I = "int", N = "double", S = "string", T = "TableEx"}

-- Make the output content.
local tmpl_env =
{
    _parent=_G,
    _escape='>',
    _debug=true,
    config=spec.config,
    lua_funcs=spec.lua_export_funcs,
    host_funcs=spec.host_export_funcs,
    klex_types=klex_types,
    cs_types=cs_types
}

rendered, err, dcode = tmpl.substitute(t, tmpl_env)

if err == nil then -- ok
    return rendered
else -- failed, look at intermediary
    return dcode, err
end
