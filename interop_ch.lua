-- Generate C specific interop code.

local ut = require('utils')
local tmpl = require('template')

-- Get specification.
local args = {...}
local spec = args[1]


---------------------------- Gen C file ----------------------------------------
local tmpl_interop_c =
[[
///// Warning - this file is created by gen_interop.lua, do not edit. /////
>local ut = require('utils')
>local sx = require("stringex")
#include "luainterop.h"
>if config.add_refs ~= nil then
>for _, inc in ipairs(config.add_refs) do
#include $(inc)
>end
>end

#if defined(_MSC_VER)
// Ignore some generated code warnings
#pragma warning( push )
#pragma warning( disable : 6001 4244 4703 4090 )
#endif

static const char* _error;

//---------------- Call lua functions from host -------------//

>for _, func in ipairs(script_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, c_types[arg.type].." "..arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
//--------------------------------------------------------//
>if #sargs > 0 then
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l, $(sargs))
>else
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l)
>end -- #sargs
{
    _error = NULL;
    int stat = LUA_OK;
    int num_args = 0;
    int num_ret = 1;
    $(c_ret_type) ret = 0;

    // Get function.
    int ltype = lua_getglobal(l, "$(func.lua_func_name)");
    if (ltype != LUA_TFUNCTION)
    {
        if ($(func.required)) { _error = "Bad function name: $(func.lua_func_name)()"; }
        return ret;
    }

    // Push arguments. No error checking required.
>for _, arg in ipairs(func.args or {}) do
>local lua_arg_type = lua_types[arg.type]
    lua_push$(lua_arg_type)(l, $(arg.name));
    num_args++;
>end -- func.args

    // Do the protected call.
    stat = luaex_docall(l, num_args, num_ret);
    if (stat == LUA_OK)
    {
        // Get the results from the stack.
        if (lua_is$(lua_ret_type)(l, -1)) { ret = lua_to$(lua_ret_type)(l, -1); }
        else { _error = "Bad return type for $(func.lua_func_name)(): should be $(lua_ret_type)"; }
    }
    else { _error = lua_tostring(l, -1); }
    lua_pop(l, num_ret); // Clean up results.
    return ret;
}

>end -- script_funcs

//---------------- Call host functions from Lua -------------//

>for _, func in ipairs(host_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
//--------------------------------------------------------//
// Lua call host: $(func.description or "")
// @param[in] l Internal lua state.
// @return Number of lua return values.
>for _, arg in ipairs(func.args or {}) do
// Lua arg: $(arg.name) $(arg.description or "")
>end -- func.args
// Lua return: $(c_ret_type) $(func.ret.description or "")
static int luainterop_$(func.host_func_name)(lua_State* l)
{
    // Get arguments
>for i, arg in ipairs(func.args or {}) do
>local lua_arg_type = lua_types[arg.type]
>local c_arg_type = c_types[arg.type]
    $(c_arg_type) $(arg.name);
    if (lua_is$(lua_arg_type)(l, $(i))) { $(arg.name) = lua_to$(lua_arg_type)(l, $(i)); }
    else { luaL_error(l, "Bad arg type for: $(arg.name)"); }
>end -- func.args

    // Do the work. One result.
>local arg_specs = { }
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
>if #sargs > 0 then
    $(c_ret_type) ret = luainteropwork_$(func.host_func_name)($(sargs));
>else
    $(c_ret_type) ret = luainteropwork_$(func.host_func_name)();
>end -- #sargs
    lua_push$(lua_ret_type)(l, ret);
    return 1;
}

>end -- host_funcs

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

const char* luainterop_Error()
{
    return _error;
}

#if defined(_MSC_VER)
#pragma warning( pop )
#endif
]]


---------------------------- Gen H file ----------------------------------------
local tmpl_interop_h =
[[
#ifndef LUAINTEROP_H
#define LUAINTEROP_H

///// Warning - this file is created by gen_interop.lua, do not edit. /////
>local ut = require('utils')
>local sx = require("stringex")

#include <stdbool.h>

#ifdef __cplusplus
#include "lua.hpp"
extern "C" {
#include "luaex.h"
};
#else
#include "lua.h"
#include "luaex.h"
#endif

//---------------- Call lua functions from host -------------//

>for _, func in ipairs(script_funcs) do
>local lua_ret_type = lua_types[func.ret.type]
>local c_ret_type = c_types[func.ret.type]
/// Host call lua: $(func.description or "")
/// @param[in] l Internal lua state.
>for _, arg in ipairs(func.args or {}) do
/// @param[in] $(arg.name) $(arg.description or "")
>end -- func.args
/// @return $(c_ret_type) $(func.ret.description or "")
>local arg_specs = {}
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, c_types[arg.type].." "..arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
>if #sargs > 0 then
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l, $(sargs));
>else
$(c_ret_type) luainterop_$(func.host_func_name)(lua_State* l);
>end -- #sargs

>end -- script_funcs

//---------------- Work functions for lua call host -------------//
>for _, func in ipairs(host_funcs) do

/// $(func.description or "")
>for _, arg in ipairs(func.args or {}) do
/// @param[in] $(arg.name) $(arg.description or "")
>end -- func.args
/// @return $(func.ret.description)
>local arg_specs = { }
>for _, arg in ipairs(func.args or {}) do
>table.insert(arg_specs, c_types[arg.type].." "..arg.name)
>end -- func.args
>sargs = sx.strjoin(", ", arg_specs)
$(c_types[func.ret.type]) luainteropwork_$(func.host_func_name)($(sargs));
>end -- host_funcs

//---------------- Infrastructure ----------------------//

/// Load Lua C lib.
void luainterop_Load(lua_State* l);

/// Return operation error or NULL if ok.
const char* luainterop_Error();

#endif // LUAINTEROP_H
]]


----------------------------------------------------------------------------
-- Type name conversions.
local lua_types = { B = "boolean", I = "integer", N = "number", S ="string" }
local c_types = { B = "bool", I = "int", N = "double", S = "const char*" }

-- Make the output content.
local tmpl_env =
{
    _parent=_G,
    _escape='>',
    _debug=true,
    config=spec.config,
    script_funcs=spec.script_funcs,
    host_funcs=spec.host_funcs,
    lua_types=lua_types,
    c_types=c_types
}

local ret = {}

-- c interop part
local rendered, err, dcode = tmpl.substitute(tmpl_interop_c, tmpl_env)
if not err then -- ok
    ret["luainterop.c"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

-- h interop part
rendered, err, dcode = tmpl.substitute(tmpl_interop_h, tmpl_env)
if not err then -- ok
    ret["luainterop.h"] = rendered
else -- failed, look at intermediary code
    ret.err = err
    ret.dcode = dcode
end

return ret
