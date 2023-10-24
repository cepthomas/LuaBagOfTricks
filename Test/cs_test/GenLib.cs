using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using KeraLuaEx;


namespace MyLib
{
    /// <summary>An example of how to create a C# library that can be loaded by Lua.</summary>
    public partial class GenLib
    {

        /// <summary>Main execution lua state.</summary>
        readonly Lua _l = new();

        /// <summary>Need static instance for binding functions.</summary>
        static GenLib _instance;




        ///// <summary>Bound lua function.</summary>
        //readonly static LuaFunction _fPrint = PrintEx;

        ///// <summary>Bound lua function.</summary>
        //readonly static LuaFunction _fTimer = Timer;

        /// <summary>Metrics.</summary>
        static readonly Stopwatch _sw = new();
        static long _startTicks = 0;



        static bool ErrorHandler(Exception e)
        {
            //// Do something with this.
            //if (_instance._l.ThrowOnError)
            //{
            //    throw e;
            //}
            //else
            //{
            //    _logger.Error(e.Message);
            //    _logger.Error(e.StackTrace ?? "No stack");
            //}
            return false;
        }





        // #region Lifecycle
        // /// <summary>
        // /// Load the lua libs implemented in C#.
        // /// </summary>
        // /// <param name="l">Lua context</param>
        // public static void Load(Lua l)
        // {
        //     // Load app stuff. This table gets pushed on the stack and into globals.
        //     l.RequireF("api_lib", OpenMyLib, true);

        //     // Other inits.
        //     _startTicks = 0;
        //     _sw.Start();
        // }

        // /// <summary>
        // /// Internal callback to actually load the libs.
        // /// </summary>
        // /// <param name="p">Pointer to context.</param>
        // /// <returns></returns>
        // static int OpenMyLib(IntPtr p)
        // {
        //     // Open lib into global table.
        //     var l = Lua.FromIntPtr(p)!;
        //     l.NewLib(_libFuncs);

        //     return 1;
        // }

        // /// <summary>
        // /// Bind the C# functions to lua.
        // /// </summary>
        // static readonly LuaRegister[] _libFuncs = new LuaRegister[]
        // {
        //     new LuaRegister("printex", _fPrint),
        //     new LuaRegister("timer", _fTimer),
        //     new LuaRegister(null, null)
        // };
        // #endregion



        // #region Lua functions implemented in C#
        // /// <summary>
        // /// Replacement for lua print(), redirects to log.
        // /// </summary>
        // /// <param name="p">Pointer to context.</param>
        // /// <returns></returns>
        // static int PrintEx(IntPtr p)
        // {
        //     var l = Lua.FromIntPtr(p)!;

        //     // Get arguments.
        //     var s = l.ToString(-1);

        //     // Do the work.
        //     Lua.Log(Lua.Category.INF, $"printex:{s}");

        //     // Return results.
        //     return 0;
        // }

        // /// <summary>
        // /// Lua script requires a high res timestamp - msec as double.
        // /// </summary>
        // /// <param name="p">Pointer to context.</param>
        // /// <returns></returns>
        // static int Timer(IntPtr p)
        // {
        //     var l = Lua.FromIntPtr(p)!;

        //     // Get arguments.
        //     bool on = l.ToBoolean(-1);

        //     // Do the work.
        //     double totalMsec = 0;
        //     if (on)
        //     {
        //         _startTicks = _sw.ElapsedTicks; // snap
        //     }
        //     else if (_startTicks > 0)
        //     {
        //         long t = _sw.ElapsedTicks; // snap
        //         totalMsec = (t - _startTicks) * 1000D / Stopwatch.Frequency;
        //     }

        //     // Return results.
        //     l.PushNumber(totalMsec);
        //     return 1;
        // }
        // #endregion


    }
}
