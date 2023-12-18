using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using KeraLuaEx;


namespace MyLuaInteropLib
{
    /// <summary>An example of how to create a C# library that can be loaded by Lua.</summary>
    public partial class MyClass
    {
        /// <summary>Main execution lua state.</summary>
        readonly Lua _l;

        /// <summary>Metrics.</summary>
        readonly Stopwatch _sw = new();
        readonly long _startTicks = 0;

        #region Lifecycle
        /// <summary>
        /// Load the lua libs implemented in C#.
        /// </summary>
        /// <param name="l">Lua context.</param>
        public MyClass(Lua l)
        {
            _l = l;

            // Load our lib stuff.
            LoadInterop();

            // Other inits.
            _startTicks = 0;
            _sw.Start();
        }
        #endregion

        #region Bound lua work functions
        /// <summary>
        /// Interop error handler. Do something with this - log it or other.
        /// </summary>
        /// <param name="e"></param>
        /// <returns></returns>
        bool ErrorHandler(Exception e)
        {
            Debug.WriteLine(e.ToString());
            return false;
        }

        /// <summary>
        /// Do something with this.
        /// </summary>
        /// <param name="arg_one"></param>
        /// <returns></returns>
        bool MyLuaFunc3_Work(double? arg_one)
        {
            return arg_one < 100.0;
        }

        /// <summary>
        /// Do something with this.
        /// </summary>
        /// <returns></returns>
        double FuncWithNoArgs_Work()
        {
            return 1234.5;
        }
        #endregion
    }
}
