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

        /// <summary>Metrics.</summary>
        readonly Stopwatch _sw = new();
        long _startTicks = 0;

        #region Lifecycle
        /// <summary>
        /// Load the lua libs implemented in C#.
        /// </summary>
        public GenLib()
        {
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
        static bool ErrorHandler(Exception e)
        {
            return false;
        }

        /// <summary>
        /// Do something with this.
        /// </summary>
        /// <param name="arg_one"></param>
        /// <returns></returns>
        static bool MyLuaFuncWork(double? arg_one)
        {
            return arg_one < 100.0;
        }

        /// <summary>
        /// Do something with this.
        /// </summary>
        /// <returns></returns>
        static double FuncWithNoArgsWork()
        {
            return 1234.5;
        }
        #endregion
    }
}
