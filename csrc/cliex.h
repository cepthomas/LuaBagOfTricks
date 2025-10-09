#pragma once

using namespace System;
using namespace System::Collections::Generic;

#include "lua.h"

/// <summary>Managed version of lua codes plus some extras.</summary>
public enum class LuaStatus : int
{
    /// <summary>No error.</summary>
    OK = LUA_OK,
    /// <summary>Not an error.</summary>
    YIELD = LUA_YIELD,
    /// <summary>Runtime error e.g bad arg type.</summary>
    ERRRUN = LUA_ERRRUN,
    /// <summary>Syntax error during pre-compilation (file load not runtime - e.g. language violation).</summary>
    ERRSYNTAX = LUA_ERRSYNTAX,
    /// <summary>Memory allocation error.</summary>
    ERRMEM = LUA_ERRMEM,
    /// <summary>Error while running the error handler function.</summary>
    ERRERR = LUA_ERRERR,
    /// <summary>Couldn't open the given file.</summary>
    ERRFILE = LUA_ERRFILE,
    //============ added ==============//
    /// <summary>Script calls api function with invalid argument.</summary>
    ERRARG = 10,
    /// <summary>Interop internal.</summary>
    ERRINTEROP = 11,
    /// <summary>Debug flag.</summary>
    DEBUG = 99,
};


//------------------ API class -------------------//

public ref class CliEx
{
protected:
    /// <summary>The lua thread.</summary>
    lua_State* _l = nullptr;

    /// <summary>Construct.</summary>
    CliEx();

    /// <summary>Clean up resources.</summary>
    ~CliEx();

    /// <summary>Initialize everything lua.</summary>
    /// <param name="luaPath">LUA_PATH</param>
    void InitLua(String^ luaPath);

    /// <summary>Load and execute a script file.</summary>
    /// <param name="fn">Full file path</param>
    void OpenScript(String^ fn);

    /// <summary>Load and execute a string as lua code.</summary>
    /// <param name="code">The code chunk</param>
    void OpenChunk(String^ code);

    /// <summary>Checks lua status and throws exception if it failed.</summary>
    /// <param name="stat">Lua status</param>
    /// <param name="msg">Info</param>
    void EvalLuaStatus(LuaStatus stat, String^ msg);

    /// <summary>Checks lua interop error and throws exception if it failed.</summary>
    /// <param name="err">Error message or NULL if ok</param>
    /// <param name="info">Extra info</param>
    void EvalInterop(const char* err, const char* info);

    /// <summary>Convert managed string to unmanaged. Only use within a SCOPE() context.</summary>
    const char* ToCString(String^ input);
};


//------------------ Utilities ------------------//

/// <summary>Exception used for lua errors.
///  - lua code: the standard lua error codes
///  - syntax: file load or runtime
///  - ???
/// </summary>
public ref struct LuaException : public System::Exception
{
private:
    LuaStatus _status;
    String^ _info;
    String^ _context;

public:
    LuaException(LuaStatus status, String^ info, String^ context) : Exception()
    {
        _status = status;
        _info = info;
        _context = context;
    }

    property LuaStatus Status { LuaStatus get() { return _status; } }

    property String^ Info { String^ get() { return _info; } }

    property String^ Context { String^ get() { return _context; } }

    virtual property String^ Message { String^ get() override { return _status.ToString() + " " + _info; } }
};


/// <summary>Critical section guard for interop functions. Also automatically frees any contained ToCstring() returns.</summary>
public class Scope
{
public:
    Scope();
    virtual ~Scope();
};
#define SCOPE() Scope _scope;

