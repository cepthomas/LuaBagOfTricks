using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;

ADD_USING

WARNING // Warning about generated file - do not edit.


namespace NAMESPACE
{
    public partial class CLASS_NAME
    {
        //---------------- Call lua functions from host - export_lua_funcs -------------//
        public RET_TYPE? HOST_FUNC_NAME(ARG_TYPE_1 ARG_NAME_1, ARG_TYPE_2 ARG_NAME_2, ARG_TYPE_3 ARG_NAME_3, ...)
        {
            RET_TYPE? ret = null;

            // Get function.
            LuaType ltype = _l.GetGlobal(LUA_FUNC_NAME);
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: {LUA_FUNC_NAME}")); return null; }

            // Push arguments - loop.
            _l.Push_ARG_TYPE_1(ARG_NAME_1);
            _l.Push_ARG_TYPE_2(ARG_NAME_2);
            _l.Push_ARG_TYPE_3(ARG_NAME_3);

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
        static int HOST_FUNC_NAME(IntPtr p)
        {
            Lua? l = Lua.FromIntPtr(p);

            // Get arguments - loop.
            ARG_TYPE_1? ARG_NAME_1 = null;
            ARG_TYPE_2? ARG_NAME_2 = null;
            if (l!.Is_ARG_TYPE_1(1)) { ARG_NAME_1 = l.To_ARG_TYPE_1(1); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {ARG_NAME_1}")); return 0; }
            if (l!.Is_ARG_TYPE_2(2)) { ARG_NAME_2 = l.To_ARG_TYPE_2(2); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {ARG_NAME_2}")); return 0; }

            // Do the work.
            RET_TYPE ret = WORK_FUNC(ARG_NAME_1, ARG_NAME_2, ...);

            // Return result (one).
            l.Push_RET_TYPE(ret);

            return 1;
        }


        //------------------ Infrastructure ----------------------//
        readonly LuaRegister[] _libFuncs = new LuaRegister[]
        {
            new LuaRegister(export_host_funcs.LUA_FUNC_NAME, export_host_funcs.HOST_FUNC_NAME),
            // etc ... 
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
