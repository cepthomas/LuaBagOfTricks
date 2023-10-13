// Warning - this is a generated file, do not edit.

using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;
ADD_USING


namespace NAMESPACE
{
    public partial class CLASS_NAME // LuaInterop or ???
    {
        //---------------- Call lua functions from host - export_lua_funcs -------------//
        // ALL functions - LOOP

        /// <summary>func.DESCRIPTION</summary>
        /// <param name="ARG1_NAME">ARG1_DESCRIPTION</param>
        ///...
        /// <returns>RET_TYPE RET_DESCRIPTION></returns>
        public RET_TYPE? HOST_FUNC_NAME(ARG1_TYPE ARG1_NAME, ARG2_TYPE ARG2_NAME, ARG3_TYPE ARG3_NAME, ...)
        {
            RET_TYPE? ret = null;

            // Get function.
            LuaType ltype = _l.GetGlobal(LUA_FUNC_NAME);
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: {LUA_FUNC_NAME}")); return null; }

            // Push arguments - LOOP.
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

        //---------------- Call host functions from Lua - export_host_funcs -------------//
        // ALL functions - LOOP

        /// <summary>func.DESCRIPTION</summary>
        /// <param name="ARG1_NAME">ARG1_DESCRIPTION</param>
        ///...
        /// <returns>RET_TYPE RET_DESCRIPTION></returns>
        static int HOST_FUNC_NAME(IntPtr p)
        {
            Lua? l = Lua.FromIntPtr(p);

            // Get arguments - LOOP.
            ARG1_TYPE? ARG1_NAME = null;
            if (l!.Is_ARG1_TYPE(1)) { ARG1_NAME = l.To_ARG1_TYPE(1); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {ARG1_NAME}")); return 0; }
            ARG2_TYPE? ARG2_NAME = null;
            if (l!.Is_ARG2_TYPE(2)) { ARG2_NAME = l.To_ARG2_TYPE(2); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {ARG2_NAME}")); return 0; }
            // ...

            // Do the work.
            RET_TYPE ret = WORK_FUNC(ARG1_NAME, ARG2_NAME, ...);

            // Return result (one).
            l.Push_RET_TYPE(ret);

            return 1;
        }


        //------------------ Infrastructure ----------------------//
        readonly LuaRegister[] _libFuncs = new LuaRegister[]
        {
            // ALL collected
            new LuaRegister(export_host_funcs.LUA_FUNC_NAME, export_host_funcs.HOST_FUNC_NAME),
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
