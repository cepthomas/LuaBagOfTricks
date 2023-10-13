using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;

namespace Ephemera.Nebulua
{
    public partial class Script
    {
        // generator fills these in:
        // static string my_lua_func_name_1 = "call_my_lua_func";
        // static string my_lua_func_name_2 = "call_my_host_func";
        // static string lib_name = "neb_api";
        // static int num_args;
        // static int num_ret;
        ////////////////////////////

        //---------------- Call lua functions from host -------------//
        public TableEx? interop_HostCallLua(string arg1, int arg2, TableEx arg3)
        {
            LuaType ltype = _l.GetGlobal(my_lua_func_name_1);
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: {my_lua_func_name_1}")); return null; }
            // Push arguments.
            _l.PushString(arg1);
            _l.PushInteger(arg2);
            _l.PushTableEx(arg3);
            // Do the actual call.
            LuaStatus lstat = _l.DoCall(num_args, num_ret);
            if (lstat >= LuaStatus.ErrRun) { ErrorHandler(new SyntaxException("DoCall() failed")); return null; }
            // Get the results from the stack.
            var tbl = _l.ToTableEx(-1);
            if (tbl is null) { ErrorHandler(new SyntaxException("Return value is not a $table$")); return null; }
            _l.Pop(num_ret);
            return tbl;
        }

        //---------------- Call host functions from Lua -------------//
        static int interop_LuaCallHost(IntPtr p)
        {
            Lua? l = Lua.FromIntPtr(p);
            int? arg1 = null;
            string? arg2 = null;
            // Get args.
            if (l!.IsInteger(1)) { arg1 = l.ToInteger(1); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for $arg1$")); return 0; }
            if (l!.IsString(2)) { arg2 = l.ToStringL(2); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for $arg2$")); return 0; }
            // Do the work.
            double ret = LuaCallHost_DoWork(arg1, arg2);
            // Return results.
            l.PushNumber(ret);
            return 1;
        }


        //------------------ Infrastructure ----------------------//
        public void Script_init()
        {
            _l.RequireF(lib_name, OpenMyLib, true);
        }

        int OpenMyLib(IntPtr p)
        {
            var l = Lua.FromIntPtr(p)!;
            l.NewLib(_libFuncs);
            return 1;
        }

        readonly LuaRegister[] _libFuncs = new LuaRegister[]
        {
            new LuaRegister(my_lua_func_name_2, interop_LuaCallHost),
            // etc new LuaRegister(my_lua_func_name_2, interop_LuaCallHost),
            new LuaRegister(null, null)
        };
    }
}
