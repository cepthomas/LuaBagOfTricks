#include <windows.h>
#include <wchar.h>
#include <vcclr.h>
extern "C" {
#include "luaex.h"
};
#include "InteropCore.h"


using namespace System;
using namespace System::Collections::Generic;
using namespace System::Text;

// This struct decl makes a vestigial warning go away per https://github.com/openssl/openssl/issues/6166.
struct lua_State {};


//=============== Critical section ====================
static CRITICAL_SECTION _critsect;
InteropCore::ContextLock::ContextLock() { EnterCriticalSection(&_critsect); }
InteropCore::ContextLock::~ContextLock() { LeaveCriticalSection(&_critsect); }


//=============== Main class ==========================

//--------------------------------------------------------//
InteropCore::Core::Core()
{
    InitializeCriticalSection(&_critsect);
    _Debug("Core()");
}

//--------------------------------------------------------//
InteropCore::Core::~Core()
{
    _Debug("~Core()");

    // Finished. Clean up resources and go home.
    DeleteCriticalSection(&_critsect);

    if (_l != nullptr)
    {
        lua_close(_l);
        _l = nullptr;
    }
}

//--------------------------------------------------------//
void InteropCore::Core::InitLua(List<String^>^ luaPath)
{
    // Init lua. Maybe clean up first.
    if (_l != nullptr)
    {
        lua_close(_l);
    }
    _l = luaL_newstate();

    // Load std libraries.
    luaL_openlibs(_l);

    // Fix lua path.
    if (luaPath->Count > 0)
    {
        // https://stackoverflow.com/a/4156038
        lua_getglobal(_l, "package");
        lua_getfield(_l, -1, "path");
        String^ currentPath = gcnew String(lua_tostring(_l, -1));

        StringBuilder^ sb = gcnew StringBuilder(currentPath);
        sb->Append(";"); // default lua path doesn't have this.
        for each (String^ lp in luaPath) // add app specific.
        {
            sb->Append(String::Format("{0}\\?.lua;", lp));
        }
        String^ newPath = sb->ToString();

        lua_pop(_l, 1);
        lua_pushstring(_l, ToCString(newPath));
        lua_setfield(_l, -2, "path");
        lua_pop(_l, 1);
    }
}

//--------------------------------------------------------//
void InteropCore::Core::OpenScript(String^ fn)
{
    int lstat = LUA_OK;
    int ret = 0;

    LOCK();

    if (_l == nullptr)
    {
        _EvalLuaStatus(-1, "You forgot to call Init().");
    }

    // Load the script into memory.
    // Pushes the compiled chunk as a lua function on top of the stack or pushes an error message.
    lstat = luaL_loadfile(_l, ToCString(fn));
    _EvalLuaStatus(lstat, "Load script file failed.");

    // Execute the script to initialize it. This reports runtime syntax errors.
    // Do the protected call. Use extended version which adds a stacktrace.
    lstat = luaex_docall(_l, 0, 0);
    _EvalLuaStatus(lstat, "Execute script failed.");
}


//------------------- Privates ---------------------------//

//--------------------------------------------------------//
void InteropCore::Core::_EvalLuaStatus(int lstat, String^ info)
{
    if (lstat == LUA_OK)
    {
        return;
    }

    // Translate between internal lua status and client status.
    String^ stat;
    switch (lstat)
    {
        case LUA_ERRSYNTAX: stat = "ScriptSyntaxError"; break;
        case LUA_ERRFILE:   stat = "ScriptFileError";   break;
        case LUA_ERRRUN:    stat = "ScriptRunError";    break;
        default:            stat = "AppInteropError";   break;
    }

    // Maybe lua error message?
    if (lstat <= LUA_ERRFILE && _l != NULL && lua_gettop(_l) > 0)
    {
        const char* smsg = lua_tostring(_l, -1);
        lua_pop(_l, 1);

        String^ mmsg = gcnew String(smsg);
        array<wchar_t>^ delims = { '\r', '\n' };
        array<String^>^ parts = mmsg->Split(delims);
        String^ s = String::Format(gcnew String("{0}: {1} [{2}]"), stat, info, parts[0]);
        throw(gcnew InteropException(s));
    }
    else // simple
    {
        throw(gcnew InteropException(String::Format(gcnew String("{0}: {1}"), stat, info)));
    }
}

//--------------------------------------------------------//
void InteropCore::Core::_EvalLuaInteropStatus(const char* err, const char* info)
{
    if (err != NULL)
    {
        String^ s = String::Format(gcnew String("LuaInteropError: {0} [{1}]"), gcnew String(info), gcnew String(err));
        throw(gcnew InteropException(s));
    }
}

//--------------------------------------------------------//
void InteropCore::Core::_Debug(String^ msg)
{
    // TODOF hook into app logging system.
    Console::WriteLine("COR: " + msg);
}


//=============== Utilities ===========================


//--------------------------------------------------------//
const char* InteropCore::ToCString(String^ input)
{
    // https://learn.microsoft.com/en-us/cpp/dotnet/how-to-access-characters-in-a-system-string?view=msvc-170
    // not! const char* str4 = context->marshal_as<const char*>(input);

    // Dirty static way:
    int inlen = input->Length;
    static char buff[1000];
    interior_ptr<const wchar_t> ppchar = PtrToStringChars(input);
    int i = 0;
    for (; *ppchar != L'\0' && i < inlen && i < sizeof(buff) - 1; ++ppchar, i++)
    {
        int c = wctob(*ppchar);
        buff[i] = c != -1 ? c : '?';
    }
    buff[i] = 0;
    return buff;

    // dynamic way:
    // int inlen = input->Length;
    // char* buff = (char*)calloc(static_cast<size_t>(inlen) + 1, sizeof(char));
    // if (buff) // shut up compiler
    // {
    //     interior_ptr<const wchar_t> ppchar = PtrToStringChars(input);
    //     for (int i = 0; *ppchar != L'\0' && i < inlen; ++ppchar, i++)
    //     {
    //         int c = wctob(*ppchar);
    //         buff[i] = c != -1 ? c : '?';
    //     }
    // }
    // return buff;
}

////--------------------------------------------------------//
//String^ InteropCore::ToManagedString(const char* input)
//{
//    return gcnew String(input);
//}
