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
    /// <param name="name">The lua ref name</param>
    void OpenChunk(String^ code, String^ name);

    /// <summary>Convert managed string to unmanaged. Only use within a SCOPE() context.</summary>
    /// <param name="input">Managed string</param>
    /// <returns>Unmanaged string</returns>
    const char* ToCString(String^ input);

private:
    /// <summary>Checks lua status and throws exception if it failed.</summary>
    /// <param name="stat">Lua status</param>
    /// <param name="msg">Info</param>
    void EvalLuaStatus(LuaStatus stat, String^ msg);
};


//------------------ Utilities ------------------//

/// <summary>Exception used for lua errors./// </summary>
public ref struct LuaException : public System::Exception
{
private:
    String^ _error = "";
    String^ _context = "";

public:
    /// <summary>Constructor.</summary>
    /// <param name="status">Standard lua code</param>
    /// <param name="error">Error info string</param>
    /// <param name="context">Lua traceback</param>
    LuaException(String^ error, String^ context);

    /// <summary>Error info string - empty if OK.</summary>
    property String^ Error { String^ get() { return _error; } }

    /// <summary>lua traceback - empty if OK.</summary>
    property String^ Context { String^ get() { return _context; } }

    /// <summary>Consolidates various flavors into one common message. Exception override.</summary>
    virtual property String^ Message { String^ get() override; }
};


/// <summary>Critical section guard for interop functions. Also automatically frees any contained ToCstring() returns.</summary>
public class Scope
{
public:
    Scope();
    virtual ~Scope();
};
#define SCOPE() Scope _scope;

