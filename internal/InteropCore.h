#pragma once

using namespace System;
using namespace System::Collections::Generic;


namespace InteropCore
{

//------ Utilities ------//

/// <summary>Convert managed string to unmanaged.</summary>
const char* ToCString(String^ input);

/// <summary>Exception used for all interop errors.</summary>
public ref struct LuaException : public System::Exception
{
public:
    LuaException(String^ message) : Exception(message) {}
};


//------ Critical section -------//

public class ContextLock
{
public:
    ContextLock();
    virtual ~ContextLock();
};
#define LOCK() ContextLock clock;


//------ Main class -------//

public ref class Core
{
public:
    /// <summary>Query for validity.</summary>
    /// <return>True if loaded</return>
    bool ScriptLoaded();

protected:
    /// <summary>The lua thread.</summary>
    lua_State* _l = nullptr;

    /// <summary>Construct.</summary>
    Core();

    /// <summary>Clean up resources.</summary>
    ~Core();

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

    /// <summary> Log from here.</summary>
    void Debug(String^ msg);
};

}