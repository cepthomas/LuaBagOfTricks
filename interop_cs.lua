
local output = {}
local function add_output(s) table.insert(output, s) end

-- arg 1
local spec = ...


-- C# flavor.
push_cs = 
{
    boolean = "PushBoolean",
    integer = "PushInteger",
    number = "PushNumber",
    string ="PushString",
    tableex = "PushTableEx"
}
is_cs = 
{
    boolean = "IsBoolean",
    integer = "IsInteger",
    number = "IsNumber",
    string ="IsString",
    tableex = "IsTableEx"
}
to_cs = 
{
    boolean = "ToBoolean",
    integer = "ToInteger",
    number = "ToNumber",
    string ="ToString",
    tableex = "ToTableEx"
}



for _, func in ipairs{spec.lua_export_funcs} do
    -- lua_func_name
    -- host_func_name
    -- description

    for _, arg in ipairs{func.args} do
        -- name
        -- type
        -- description


    end

    local ret = func.ret
    -- type
    -- description


end


function do_func(func)

end


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

preamble = 
[[
///// Warning - this is a generated file, do not edit. /////

using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;
{ADD_USING}

namespace {NAMESPACE}
{
    public partial class {CLASS_NAME}
    {
]]

lua_export_funcs = 
[[  LOOPfuncs
        /// <summary>Lua export function: {func.DESCRIPTION}</summary>
        /// <param name="{ARG1_NAME}">{ARG1_DESCRIPTION}</param> LOOPargs
        /// <param name="{ARG2_NAME}">{ARG2_DESCRIPTION}</param>
        ///...
        /// <returns>{RET_TYPE} {RET_DESCRIPTION}></returns>
        public {RET_TYPE}? HOST_FUNC_NAME(ARG1_TYPE ARG1_NAME, ARG2_TYPE ARG2_NAME, ARG3_TYPE ARG3_NAME, ...) LOOPargs
        {
            {RET_TYPE}? ret = null;

            // Get function.
            LuaType ltype = _l.GetGlobal({LUA_FUNC_NAME});
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: {{LUA_FUNC_NAME}}")); return null; }

            // Push arguments LOOPargs
            _l.Push_ARG1_TYPE(ARG1_NAME);
            _l.Push_ARG2_TYPE(ARG2_NAME);
            _l.Push_ARG3_TYPE(ARG3_NAME);
            // ...

            // Do the actual call.
            LuaStatus lstat = _l.DoCall(NUM_ARGS, NUM_RET);
            if (lstat >= LuaStatus.ErrRun) { ErrorHandler(new SyntaxException("DoCall() failed")); return null; }

            // Get the results from the stack.
            ret = _l.To_RET_TYPE(-1);
            if (ret is null) { ErrorHandler(new SyntaxException("Return value is not a RET_TYPE")); return null; }
            _l.Pop(NUM_RET);

            return ret;
        }
]]

host_export_funcs = 
[[  LOOPfuncs
        /// <summary>Host exprt function: func.DESCRIPTION</summary>
        /// <param name="ARG1_NAME">ARG1_DESCRIPTION</param> LOOPargs.
        ///...
        /// <returns>RET_TYPE RET_DESCRIPTION></returns>
        static int HOST_FUNC_NAME(IntPtr p)
        {
            Lua? l = Lua.FromIntPtr(p);

            // Get arguments LOOPargs
            ARG1_TYPE? ARG1_NAME = null;
            if (l!.Is_ARG1_TYPE(1)) { ARG1_NAME = l.To_ARG1_TYPE(1); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {ARG1_NAME}")); return 0; }
            ARG2_TYPE? ARG2_NAME = null;
            if (l!.Is_ARG2_TYPE(2)) { ARG2_NAME = l.To_ARG2_TYPE(2); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {ARG2_NAME}")); return 0; }
            // ...

            // Do the work.
            RET_TYPE ret = WORK_FUNC(ARG1_NAME, ARG2_NAME, ...); LOOPargs

            // Return result (one).
            l.Push_RET_TYPE(ret);

            return 1;
        }
]]

postamble = 
[[
        //------------------ Infrastructure ----------------------//
        readonly LuaRegister[] _libFuncs = new LuaRegister[]
        {
            // ALL collected LOOPfuncs
            new LuaRegister(host_export_funcs.LUA_FUNC_NAME, host_export_funcs.HOST_FUNC_NAME),
            //... 
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
            _l.RequireF(LIB_NAME, InteropOpen, true);
        }
    }
}
]]


return output
