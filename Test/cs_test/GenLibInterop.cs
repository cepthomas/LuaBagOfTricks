///// Warning - this file is created by gen_interop.lua, do not edit. /////
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using KeraLuaEx;
using System.Diagnostics;

namespace MyLib
{
    public partial class GenLib
    {
        #region Functions exported from lua for execution by host
        /// <summary>Lua export function: booga</summary>
        /// <param name="arg_one">some strings</param>
        /// <param name="arg_two">a nice integer</param>
        /// <param name="arg_three">3 ddddddddd</param>
        /// <returns>TableEx a returned thing></returns>
        public TableEx? MyLuaFunc(string arg_one, int arg_two, TableEx arg_three)
        {
            int numArgs = 0;
            int numRet = 1;

            // Get function.
            LuaType ltype = _l.GetGlobal("my_lua_func");
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: my_lua_func")); return null; }

            // Push arguments
            _l.PushString(arg_one);
            numArgs++;
            _l.PushInteger(arg_two);
            numArgs++;
            _l.PushTableEx(arg_three);
            numArgs++;

            // Do the actual call.
            LuaStatus lstat = _l.DoCall(numArgs, numRet);
            if (lstat >= LuaStatus.ErrRun) { ErrorHandler(new SyntaxException("DoCall() failed")); return null; }

            // Get the results from the stack.
            TableEx? ret = _l.ToTableEx(-1);
            if (ret is null) { ErrorHandler(new SyntaxException("Return value is not a TableEx")); return null; }
            _l.Pop(1);
            return ret;
        }
        /// <summary>Lua export function: booga2</summary>
        /// <param name="arg_one">bbbbbbb</param>
        /// <returns>double a returned number></returns>
        public double? MyLuaFunc2(bool arg_one)
        {
            int numArgs = 0;
            int numRet = 1;

            // Get function.
            LuaType ltype = _l.GetGlobal("my_lua_func2");
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: my_lua_func2")); return null; }

            // Push arguments
            _l.PushBoolean(arg_one);
            numArgs++;

            // Do the actual call.
            LuaStatus lstat = _l.DoCall(numArgs, numRet);
            if (lstat >= LuaStatus.ErrRun) { ErrorHandler(new SyntaxException("DoCall() failed")); return null; }

            // Get the results from the stack.
            double? ret = _l.ToNumber(-1);
            if (ret is null) { ErrorHandler(new SyntaxException("Return value is not a double")); return null; }
            _l.Pop(1);
            return ret;
        }
        /// <summary>Lua export function: no_args</summary>
        /// <returns>double a returned number></returns>
        public double? NoArgsFunc()
        {
            int numArgs = 0;
            int numRet = 1;

            // Get function.
            LuaType ltype = _l.GetGlobal("no_args_func");
            if (ltype != LuaType.Function) { ErrorHandler(new SyntaxException($"Bad lua function: no_args_func")); return null; }

            // Push arguments

            // Do the actual call.
            LuaStatus lstat = _l.DoCall(numArgs, numRet);
            if (lstat >= LuaStatus.ErrRun) { ErrorHandler(new SyntaxException("DoCall() failed")); return null; }

            // Get the results from the stack.
            double? ret = _l.ToNumber(-1);
            if (ret is null) { ErrorHandler(new SyntaxException("Return value is not a double")); return null; }
            _l.Pop(1);
            return ret;
        }
        #endregion

        #region Functions exported from host for execution by lua
        /// <summary>Host export function: fooga
        /// Lua arg: "arg_one">kakakakaka
        /// Lua return: bool a returned thing>
        /// </summary>
        /// <param name="p">Internal lua state</param>
        /// <returns>Number of lua return values></returns>
        static int MyLuaFunc(IntPtr p)
        {
            Lua l = Lua.FromIntPtr(p)!;

            // Get arguments
            double? arg_one = null;
            if (l.IsNumber(1)) { arg_one = l.ToNumber(1); }
            else { ErrorHandler(new SyntaxException($"Bad arg type for {arg_one}")); return 0; }

            // Do the work. One result.
            bool ret = MyLuaFuncWork(arg_one);
            l.PushBoolean(ret);
            return 1;
        }
        /// <summary>Host export function: Func with no args
        /// Lua return: double a returned thing>
        /// </summary>
        /// <param name="p">Internal lua state</param>
        /// <returns>Number of lua return values></returns>
        static int FuncWithNoArgs(IntPtr p)
        {
            Lua l = Lua.FromIntPtr(p)!;

            // Get arguments

            // Do the work. One result.
            double ret = FuncWithNoArgsWork();
            l.PushNumber(ret);
            return 1;
        }
        #endregion

        #region Infrastructure
        readonly LuaRegister[] _libFuncs = new LuaRegister[]
        {
            // ALL collected.
            new LuaRegister("my_lua_func", MyLuaFunc),
            new LuaRegister("func_with_no_args", FuncWithNoArgs),
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
            _l.RequireF("", OpenInterop, true);
        }
        #endregion
    }
}