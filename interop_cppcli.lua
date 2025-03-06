-- Generate .NET C++/CLI interop code.

local ut = require('lbot_utils')
local tmpl = require('template')

-- Get specification.
local args = {...}
local spec = args[1]


--------------------------------------------------------------------------------
---------------------------- Gen C++ file --------------------------------------
--------------------------------------------------------------------------------
local tmpl_interop_cpp =
[[
>local ut = require('lbot_utils')
>local sx = require("stringex")
>local os = require("os")
>local snow = os.date('%Y-%m-%d %H:%M:%S')
///// Warning - this file is created by gen_interop.lua - do not edit. $(snow) /////

#include <windows.h>
#include "$(config.lua_lib_name).h"
#include "$(config.host_lib_name).h"
>if config.add_refs ~= nil then
>  for _, inc in ipairs(config.add_refs) do
#include $(inc)
>  end
>end

using namespace System;
using namespace System::Collections::Generic;
using namespace Interop;

//============= C# => C functions .cpp =============//

>for _, func in ipairs(script_funcs) do
>  local arg_spec = {}
>  local arg_impl = {}
>  for _, arg in ipairs(func.args or {}) do
>    table.insert(arg_spec, cpp_types(arg.type).." "..arg.name)
>    if arg.type == 'S' then
>       table.insert(arg_impl, "ToCString("..arg.name..")")
>    else
>       table.insert(arg_impl, arg.name)
>    end
>  end -- func.args
>  sarg_spec = sx.strjoin(", ", arg_spec)
>  sarg_impl = sx.strjoin(", ", arg_impl)
//--------------------------------------------------------//
>  if #sarg_spec > 0 then
$(cpp_types(func.ret.type)) $(config.host_lib_name)::$(func.host_func_name)($(sarg_spec))
>  else
$(cpp_types(func.ret.type)) $(config.host_lib_name)::$(func.host_func_name)()
>  end -- #sarg_spec
{
    LOCK();
>    if func.ret.type == 'S' then
    $(cpp_types(func.ret.type)) ret = ToManagedString($(config.lua_lib_name)_$(func.host_func_name)(_l, $(sarg_impl)));
>    else
    $(cpp_types(func.ret.type)) ret = $(config.lua_lib_name)_$(func.host_func_name)(_l, $(sarg_impl));
>    end
    _EvalLuaInteropStatus("$(func.host_func_name)()");
    return ret;
}

>end -- script_funcs

//============= C => C# callback functions .cpp =============//

>for _, func in ipairs(host_funcs) do
>  local arg_spec = {}
>  local arg_impl = {}
>  for _, arg in ipairs(func.args or {}) do
>    table.insert(arg_spec, c_types(arg.type).." "..arg.name)
>    table.insert(arg_impl, arg.name)
>  end -- func.args
>  sarg_spec = sx.strjoin(", ", arg_spec)
>  sarg_impl = sx.strjoin(", ", arg_impl)

//--------------------------------------------------------//

int $(config.lua_lib_name)cb_$(func.host_func_name)(lua_State* l, $(sarg_spec))
{
    LOCK();
    $(func.host_func_name)Args^ args = gcnew $(func.host_func_name)Args($(sarg_impl));
    $(config.host_lib_name)::Notify(args);
    return 0;
}

>end -- host_funcs

//============= Infrastructure .cpp =============//

//--------------------------------------------------------//
void $(config.host_lib_name)::Run(String^ scriptFn, List<String^>^ luaPath)
{
    InitLua(luaPath);
    // Load C host funcs into lua space.
    $(config.lua_lib_name)_Load(_l);
    // Clean up stack.
    lua_pop(_l, 1);
    OpenScript(scriptFn);
}
]]


--------------------------------------------------------------------------------
---------------------------- Gen H file ----------------------------------------
--------------------------------------------------------------------------------
local tmpl_interop_h =
[[
>local ut = require('lbot_utils')
>local sx = require("stringex")
>local os = require("os")
>local snow = os.date('%Y-%m-%d %H:%M:%S')
///// Warning - this file is created by gen_interop.lua - do not edit. $(snow) /////

#pragma once
#include "Core.h"

using namespace System;
using namespace System::Collections::Generic;

namespace $(config.host_namespace)
{

//============= C => C# callback payload .h =============//

>for _, func in ipairs(host_funcs) do
//--------------------------------------------------------//
public ref class $(func.host_func_name)Args : public EventArgs
{
public:
>  local arg_spec = {}
>  for _, arg in ipairs(func.args or {}) do
>    table.insert(arg_spec, c_types(arg.type).." "..arg.name)
    /// <summary>$(arg.description)</summary>
    property $(cpp_types(arg.type)) $(arg.name);
>  end -- func.args
>  sarg_spec = sx.strjoin(", ", arg_spec)
    /// <summary>Constructor.</summary>
    $(func.host_func_name)Args($(sarg_spec))
    {
>  for _, arg in ipairs(func.args or {}) do
>    if arg.type == 'S' then
        this->$(arg.name) = gcnew String($(arg.name));
>    else
        this->$(arg.name) = $(arg.name);
>    end
>  end -- func.args
    }
};

>end -- host_funcs

//----------------------------------------------------//
public ref class $(config.host_lib_name) : Core
{

//============= C# => C functions .h =============//
public:

>for _, func in ipairs(script_funcs) do
>  local arg_spec = {}
    /// <summary>$(func.host_func_name)</summary>
>  for _, arg in ipairs(func.args or {}) do
>    table.insert(arg_spec, cpp_types(arg.type).." "..arg.name)
    /// <param name="$(arg.name)">$(arg.description)</param>
>  end -- func.args
>  sarg_spec = sx.strjoin(", ", arg_spec)
    /// <returns>Script return</returns>
    $(cpp_types(func.ret.type)) $(func.host_func_name)($(sarg_spec));

>end -- script_funcs
//============= C => C# callback functions =============//
public:
>for _, func in ipairs(host_funcs) do
    static event EventHandler<$(func.host_func_name)Args^>^ $(func.host_func_name);
    static void Notify($(func.host_func_name)Args^ args) { $(func.host_func_name)(nullptr, args); }

>end -- host_funcs

//============= Infrastructure .h =============//
public:
    /// <summary>Initialize and execute.</summary>
    /// <param name="scriptFn">The script to load.</param>
    /// <param name="luaPath">LUA_PATH components</param>
    void Run(String^ scriptFn, List<String^>^ luaPath);
};

}
]]


----------------------------------------------------------------------------

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
    c_types=function(t)
        if t == 'B' then return "bool"
        elseif t == 'I' then return "int"
        elseif t == 'N' then return "double"
        elseif t == 'S' then return "const char*"
        else return 'Invalid spec type: '..t
        end
    end,
    cpp_types=function(t)
        if t == 'B' then return "bool"
        elseif t == 'I' then return "int"
        elseif t == 'N' then return "double"
        elseif t == 'S' then return "String^"
        else return 'Invalid spec type: '..t
        end
    end
}

local ret = {}

-- cpp interop part
print('Generating cpp file')
local rendered, err, dcode = tmpl.substitute(tmpl_interop_cpp, tmpl_env)
if not err then -- ok
    ret[spec.config.host_lib_name..".cpp"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

-- h interop part
print('Generating h file')
rendered, err, dcode = tmpl.substitute(tmpl_interop_h, tmpl_env)
if not err then -- ok
    ret[spec.config.host_lib_name..".h"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

return ret
