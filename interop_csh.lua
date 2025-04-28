-- Generate C# specific interop code. Requires KeraLuaEx to compile.

-- local ut = require('lbot_utils')
local tmpl = require('template')

-- Get specification.
local args = {...}
local spec = args[1]


--------------------------------------------------------------------------------
---------------------------- Gen C# file ---------------------------------------
--------------------------------------------------------------------------------
local tmpl_src =
[[
>local ut = require('lbot_utils')
>local sx = require("stringex")
>local os = require("os")
>local snow = os.date('%Y-%m-%d %H:%M:%S')
///// Warning - this file is created by gen_interop.lua - do not edit. /////

using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;
>if config.add_refs then
>for _, us in ipairs(config.add_refs) do
using $(us);
>end
>end

namespace $(config.namespace)
{
    public partial class $(config.class_name)
    {
        #region ============= C# => KeraLuaEx functions =============

>for _, func in ipairs(script_funcs) do
>local klex_ret_type = klex_types(func.ret.type)
>local cs_ret_type = cs_types(func.ret.type)
        /// <summary>Lua export function: $(func.description or "")</summary>
>for _, arg in ipairs(func.args or {}) do
        /// <param name="$(arg.name)">$(arg.description or "")</param>
>end -- func.args
        /// <returns>$(cs_ret_type) $(func.ret.description or "")></returns>
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, cs_types(arg.type) .. " " .. arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
        public $(cs_ret_type)? $(func.host_func_name)($(sargs))
        {
            int numArgs = 0;
            int numRet = 1;

            // Get function.
            LuaType ltype = _l.GetGlobal("$(func.lua_func_name)");
            if (ltype != LuaType.Function) { throw new SyntaxException("", -1, $"Invalid lua function: $(func.lua_func_name)"); }

            // Push arguments.
>for _, arg in ipairs(func.args or {}) do
>local klex_arg_type = klex_types(arg.type)
            _l.Push$(klex_arg_type)($(arg.name));
            numArgs++;
>end -- func.args

            // Do the actual call.
            LuaStatus lstat = _l.DoCall(numArgs, numRet);
            if (lstat >= LuaStatus.ErrRun) { throw new LuaException("", -1, lstat, "DoCall() failed"); }

            // Get the results from the stack.
            $(cs_ret_type)? ret = _l.To$(klex_ret_type)(-1);
            if (ret is null) { throw new SyntaxException("", -1, "$(func.host_func_name) return value is not a $(cs_ret_type)"); }
            _l.Pop(1);
            return ret;
        }

>end -- script_funcs
        #endregion

        #region ============= KeraLuaEx => C# callback functions =============s
        
>for _, func in ipairs(host_funcs) do
>local klex_ret_type = klex_types(func.ret.type)
>local cs_ret_type = cs_types(func.ret.type)
        /// <summary>Host export function: $(func.description or "")
>for _, arg in ipairs(func.args or {}) do
        /// Lua arg: "$(arg.name)" $(arg.description or "")
>end -- func.args
        /// Lua return: $(cs_ret_type) $(func.ret.description or "")
        /// </summary>
        /// <param name="p">Internal lua state</param>
        /// <returns>Number of lua return values></returns>
        int $(func.host_func_name)(IntPtr p)
        {
            Lua l = Lua.FromIntPtr(p)!;

            // Get arguments
>for i, arg in ipairs(func.args or {}) do
>local klex_arg_type = klex_types(arg.type)
>local cs_arg_type = cs_types(arg.type)
            $(cs_arg_type)? $(arg.name) = null;
            if (l.Is$(klex_arg_type)($(i))) { $(arg.name) = l.To$(klex_arg_type)($(i)); }
            else { throw new SyntaxException("", -1, "Invalid arg type: $(func.lua_func_name)($(arg.name))"); }
>end -- func.args

            // Do the work. Always one result.
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
            $(cs_ret_type) ret = $(func.host_func_name)Cb($(sargs));
            l.Push$(klex_ret_type)(ret);
            return 1;
        }

>end -- host_funcs
        #endregion

        #region ============= Infrastructure =============

        readonly List<LuaRegister> _libFuncs = new();
        readonly Lua _l = new ();

        int OpenInterop(IntPtr p)
        {
            var l = Lua.FromIntPtr(p)!;
            l.NewLib(_libFuncs.ToArray());
            return 1;
        }

        void LoadInterop()
        {
>for _, func in ipairs(host_funcs) do
            _libFuncs.Add(new LuaRegister("$(func.lua_func_name)", $(func.host_func_name)));
>end -- host_funcs
            _libFuncs.Add(new LuaRegister(null, null));
            _l.RequireF("$(config.lua_lib_name)", OpenInterop, true);
        }

        void LoadScript(string scriptFn, List<string> lbotDirs)
        {
            _l.SetLuaPath(lbotDirs);
            LuaStatus lstat = _l.LoadFile(scriptFn);
            if (lstat >= LuaStatus.ErrRun) { throw new LuaException("", -1, lstat, "LoadScript() failed"); }
            // Run it.
            _l.PCall(0, Lua.LUA_MULTRET, 0);
            // Reset stack.
            _l.SetTop(0);
        }
        #endregion
    }
}
]]


-- Make the output content. 
local tmpl_env =
{
    _parent=_G,
    _escape='>',
    _debug=true,
    config=spec.config,
    script_funcs=spec.script_funcs,
    host_funcs=spec.host_funcs,
    -- Type name conversions.
    klex_types=function(t)
        if t == 'B' then return "Boolean"
        elseif t == 'I' then return "Integer"
        elseif t == 'N' then return "Number"
        elseif t == 'S' then return "String"
        elseif t == 'T' then return "TableEx"
        else return 'Invalid spec type: '..t
        end
    end,
    cs_types=function(t)
        if t == 'B' then return "bool"
        elseif t == 'I' then return "int"
        elseif t == 'N' then return "double"
        elseif t == 'S' then return "string"
        elseif t == 'T' then return "TableEx"
        else return 'Invalid spec type: '..t
        end
    end,
}


local ret = {}
print('Generating cs file')

local rendered, err, dcode = tmpl.substitute(tmpl_src, tmpl_env)

if not err then -- ok
    ret[spec.config.file_name..".cs"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

return ret
