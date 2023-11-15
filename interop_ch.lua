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

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"

#include "luainterop.h"
#include "luainterop_work.h"
>for _, inc in ipairs(config.add_refs) do
#include $(inc)
>end

//---------------- Call lua functions from host -------------//

>for _, func in ipairs(lua_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, c_types[arg.type] .. " " .. arg.name)
>end -- func.args
>sargs = ut.strjoin(", ", arg_specs)
>if #sargs > 0 then
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l, $(sargs))
>else
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l)
>end -- #sargs
{
    int num_args = 0;
    int num_ret = 1;

    // Get function.
    int ltype = lua_getglobal(l, "$(func.lua_func_name)");
    if (ltype != LUA_TFUNCTION) { luaL_error(l, "Bad lua function: $(func.lua_func_name)"); };

    // Push arguments.
>for _, arg in ipairs(func.args or {}) do
>local lua_arg_type = lua_types[arg.type]
    lua_push$(lua_arg_type)(l, $(arg.name));
    num_args++;
>end -- func.args

    // Do the actual call.
    int lstat = luaL_docall(l, num_args, num_ret); // optionally throws
    if (lstat >= LUA_ERRRUN) { luaL_error(l, "luaL_docall() failed: %d", lstat); }

    // Get the results from the stack.
    $(c_ret_type) ret;
    if (lua_to$(lua_ret_type)(l, -1)) { ret = lua_to$(lua_ret_type)(l, -1); }
    else { luaL_error(l, "Return is not a $(c_ret_type)"); }
    lua_pop(l, num_ret); // Clean up results.
    return ret;
}

>end -- lua_funcs

//---------------- Call host functions from Lua -------------//

>for _, func in ipairs(host_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
// Host export function: $(func.description or "")
>for _, arg in ipairs(func.args or {}) do
// Lua arg: "$(arg.name)">$(arg.description or "")
>end -- func.args
// Lua return: $(c_ret_type) $(func.ret.description or "")
// @param[in] l Internal lua state.
// @return Number of lua return values.
static int luainterop_$(func.host_func_name)(lua_State* l)
{
    // Get arguments
>for i, arg in ipairs(func.args or {}) do
>local lua_arg_type = lua_types[arg.type]
>local c_arg_type = c_types[arg.type]
    $(c_arg_type) $(arg.name);
    if (lua_is$(lua_arg_type)(l, $(i))) { $(arg.name) = lua_to$(lua_arg_type)(l, $(i)); }
    else { luaL_error(l, "Bad arg type for $(arg.name)"); }
>end -- func.args

    // Do the work. One result.
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, arg.name)
>end -- func.args
>sargs = ut.strjoin(", ", arg_specs)
>if #sargs > 0 then
    $(c_ret_type) ret = luainterop_$(func.host_func_name)_Work($(sargs));
>else
    $(c_ret_type) ret = luainterop_$(func.host_func_name)_Work();
>end -- #sargs
    lua_push$(lua_ret_type)(l, ret);
    return 1;
}

>end -- lua_funcs

//---------------- Infrastructure -------------//

static const luaL_Reg function_map[] =
{
>for _, func in ipairs(host_funcs) do
    { "$(func.lua_func_name)", luainterop_$(func.host_func_name) },
>end -- host_funcs
    { NULL, NULL }
};

static int luainterop_Open(lua_State* l)
{
    luaL_newlib(l, function_map);
    return 1;
}

void luainterop_Load(lua_State* l)
{
    luaL_requiref(l, "$(config.lua_lib_name)", luainterop_Open, true);
}
]]

local tmpl_src_h =
[[
#ifndef LUAINTEROP_H
#define LUAINTEROP_H

///// Warning - this file is created by gen_interop.lua, do not edit. /////
>local ut = require('utils')
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <float.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"

//---------------- Call lua functions from host -------------//

>for _, func in ipairs(lua_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
// Lua export function: $(func.description or "")
// @param[in] l Internal lua state.
>for _, arg in ipairs(func.args or {}) do
// @param[in] $(arg.name) $(arg.description or "")
>end -- func.args
// @return $(c_ret_type) $(func.ret.description or "")
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, c_types[arg.type] .. " " .. arg.name)
>end -- func.args
>sargs = ut.strjoin(", ", arg_specs)
>if #sargs > 0 then
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l, $(sargs));
>else
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l);
>end -- #sargs

>end -- lua_funcs

///// Infrastructure.
void luainterop_Load(lua_State* l);

#endif // LUAINTEROP_H
]]

-- Type name conversions.
local lua_types = { B = "boolean", I = "integer", N = "number", S ="string", T = "tableex" }
local c_types = { B = "bool", I = "int", N = "double", S = "char*", T = "tableex*" }

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

local ret = {} -- { "luainterop.c"=rendered, "luainterop.h"=rendered, err, dcode }

-- c part
local rendered, err, dcode = tmpl.substitute(tmpl_src_c, tmpl_env)
if not err then -- ok
    ret["luainterop.c"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

-- h part
rendered, err, dcode = tmpl.substitute(tmpl_src_h, tmpl_env)
if not err then -- ok
    ret["luainterop.h"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

return ret
