#pragma once

using namespace System;
using namespace System::Collections::Generic;


//------ Utilities ------//

/// <summary>Exception used for all interop errors.</summary>
public ref struct LuaException : public System::Exception
{
public:
    LuaException(String^ message) : Exception(message) {}
};


/// <summary>Critical section guard for interop functions. Also automatically frees any contained ToCstring() returns.</summary>
public class Scope
{
public:
    Scope();
    virtual ~Scope();
};
#define SCOPE() Scope _scope;


//------ Main class -------//

public ref class InteropCore
{
protected:
    /// <summary>The lua thread.</summary>
    lua_State* _l = nullptr;

    /// <summary>Construct.</summary>
    InteropCore();

    /// <summary>Clean up resources.</summary>
    ~InteropCore();

    /// <summary>Initialize everything lua.</summary>
    /// <param name="luaPath">LUA_PATH components</param>
    void InitLua(String^ luaPath);

    /// <summary>Load and process.</summary>
    /// <param name="fn">Full file path</param>
    void OpenScript(String^ fn);

    /// <summary>Checks lua status and throws exception if it failed.</summary>
    /// <param name="stat">Lua status</param>
    /// <param name="msg">Info</param>
    void EvalLuaStatus(int stat, String^ msg);

    /// <summary>Checks lua interop error and throws exception if it failed.</summary>
    /// <param name="err">Error message or NULL if ok</param>
    /// <param name="info">Extra info</param>
    void EvalLuaInteropStatus(const char* err, const char* info);

    /// <summary>Convert managed string to unmanaged. Only use within a SCOPE() context.</summary>
    const char* ToCString(String^ input);
};
