
-- TODO0 Create C version of the C# functionality. Actually two files or header only?





-- Generate C specific interop code.

local ut = require('utils')
local tmpl = require('template')

-- Get specification.
local args = {...}
local spec = args[1]


local tmpl_src_c =
[[
///// Warning - this file is created by gen_interop.lua, do not edit. /////
>local ut = require('utils')
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <float.h>
#include <math.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"
#include "interop_$(config.host_lib_name).h"
>for _, inc in ipairs(config.add_include) do
#include $(inc)
>end

/// Turn interrupts on/off.
/// @param[in,out] env On/off.
/// @return Status.

///// Functions exported from lua for execution by host

>for _, func in ipairs(lua_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
/// Lua export function: $(func.description or "")
>for _, arg in ipairs(func.args or {}) do
/// @param[in] $(arg.name) $(arg.description or "")
>end -- func.args
/// @return $(c_ret_type) $(func.ret.description or "")
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, c_types[arg.type] .. " " .. arg.name)
>end -- func.args
>sargs = ut.strjoin(", ", arg_specs)
$(c_ret_type) interop_$(func.host_func_name)(lua_State* l, $(sargs))
{
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "$(func.lua_func_name)");
    if (ltype != LUA_TFUNCTION) { ErrorHandler(l, LUA_ERRSYNTAX, "Bad lua function: %s", $(func.lua_func_name)); return NULL; };

    // Push arguments.
>for _, arg in ipairs(func.args or {}) do
>local lua_arg_type = lua_types[arg.type]
    lua_push$(lua_arg_type)(l, $(arg.name));
    num_args++;
>end -- func.args

    // Do the actual call.
    int lstat = luaL_docall(l, num_args, num_ret); // optionally throws
    if (lstat >= LUA_ERRRUN) { ErrorHandler(l, lstat, "luaL_docall() failed"); return NULL; }

    // Get the results from the stack.
    $(c_ret_type) ret = lua_to$(lua_ret_type)(l, -1);
    if (ret is NULL) { ErrorHandler(ErrorHandler(l, LUA_ERRSYNTAX, "Return is not a $(c_ret_type)"); return NULL; }
    lua_pop(l, num_ret); // Clean up results.
    return ret;
}

>end -- lua_funcs

///// Functions exported from host for execution by lua.

>for _, func in ipairs(host_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
/// Host export function: $(func.description or "")
>for _, arg in ipairs(func.args or {}) do
/// Lua arg: "$(arg.name)">$(arg.description or "")
>end -- func.args
/// Lua return: $(c_ret_type) $(func.ret.description or "")
/// @param[in] p Internal ua state.
/// @return Number of lua return values.
static int interop_$(func.host_func_name)(lua_State* l)
{
    // Get arguments
>for i, arg in ipairs(func.args or {}) do
>local lua_arg_type = lua_types[arg.type]
>local c_arg_type = c_types[arg.type]
    $(c_arg_type) $(arg.name);
    if (lua_is$(lua_arg_type)(l, $(i))) { $(arg.name) = lua_to$(lua_arg_type)(l, $(i)); }
    else { ErrorHandler(l, LUA_ERRSYNTAX, "Bad arg type for $(arg.name)"); return 0; }
>end -- func.args

    // Do the work. One result.
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, arg.name)
>end -- func.args
>sargs = ut.strjoin(", ", arg_specs)
    $(c_ret_type) ret = interop_$(func.host_func_name)Work($(sargs));
    lua_push$(lua_ret_type)(l, ret);
    return 1;
}

>end -- lua_funcs

///// Infrastructure.

static const luaL_Reg function_map[] =
{
>for _, func in ipairs(host_funcs) do
    _$(func.host_func_name) = interop_$(func.host_func_name);
>end -- host_funcs
    { NULL, NULL }
};

static int interop_Open(lua_State* l)
{
    luaL_newlib(l, function_map);
    return 1;
}

void interop_Load(lua_State* l)
{
    luaL_requiref(l, $(lua_lib_name), interop_Open, true);
}
]]

local tmpl_src_h =
[[
// ???
]]

-- Type name conversions.
local lua_types = { B = "boolean", I = "integer", N = "number", S ="string", T = "tableex" }
local c_types = { B = "bool", I = "int", N = "double", S = "string", T = "tableex" }

-- Make the output content.
local tmpl_env =
{
    _parent=_G,
    _escape='>',
    _debug=true,
    config=spec.config,
    lua_funcs=spec.lua_export_funcs,
    host_funcs=spec.host_export_funcs,
    lua_types=lua_types,
    c_types=c_types
}

local ret = {}

-- c part
local rendered, err, dcode = tmpl.substitute(tmpl_src_c, tmpl_env)

if not err then -- ok
    ret.c = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

-- h part
rendered, err, dcode = tmpl.substitute(tmpl_src_h, tmpl_env)

if not err then -- ok
    ret.h = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end



----------------------------- TODO add header: -----------------------------

local hhh = [[
#ifndef INTEROP_H
#define INTEROP_H

///// Warning - this file is created by gen_interop.lua, do not edit. /////

///// Call lua functions from host.
 - export_lua_funcs -------------//
// ALL export_lua_funcs - LOOP

// --------------------------------------------------------------------------
// func.DESCRIPTION
// @param ARG1_NAME ARG1_DESCRIPTION
// @param ...
// @return RET_TYPE RET_DESCRIPTION
RET_TYPE HOST_FUNC_NAME(ARG1_TYPE ARG1_NAME, ARG2_TYPE ARG2_NAME, ARG3_TYPE ARG3_NAME, ...)


///// Call host functions from Lua.
// ALL export_host_funcs - LOOP

// --------------------------------------------------------------------------
// func.DESCRIPTION
// @param ARG1_NAME ARG1_DESCRIPTION
// @param ...
// @return RET_TYPE RET_DESCRIPTION
RET_TYPE WORK_FUNC(ARG1_TYPE ARG1_NAME, ARG2_TYPE ARG2_NAME, ...);

///// Infrastructure.
void interop_Load(lua_State* l);



#endif // INTEROP_H
]]


return ret
