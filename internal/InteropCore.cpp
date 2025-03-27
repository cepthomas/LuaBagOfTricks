#include <windows.h>
#include <wchar.h>
#include <vcclr.h>
extern "C" {
#include "luaex.h"
};
#include "InteropCore.h"
#include <vector>


using namespace System;
using namespace System::Collections::Generic;
using namespace System::Text;

// This struct decl makes a vestigial warning go away per https://github.com/openssl/openssl/issues/6166.
struct lua_State {};

// Poor man's garbage collection.
std::vector<void*> _allocations = {};
static void Collect()
{
    for (void* n : _allocations)
        free(n);
    _allocations.clear();
}

//=============== Critical section ====================
static CRITICAL_SECTION _critsect;
Scope::Scope() { EnterCriticalSection(&_critsect); }
Scope::~Scope() { Collect(); LeaveCriticalSection(&_critsect); }


//=============== Main class ==========================

//--------------------------------------------------------//
InteropCore::InteropCore()
{
    InitializeCriticalSection(&_critsect);
    //Console::WriteLine("Core()");
}

//--------------------------------------------------------//
InteropCore::~InteropCore()
{
    // Finished. Clean up resources and go home.
    DeleteCriticalSection(&_critsect);

    if (_l != nullptr)
    {
        lua_close(_l);
        _l = nullptr;
    }
}

//--------------------------------------------------------//
//bool InteropCore::ScriptLoaded()
//{
//    return _l != nullptr;
//}

//--------------------------------------------------------//
void InteropCore::InitLua(String^ luaPath)
{
    SCOPE();

    // Init lua. Maybe clean up first.
    if (_l != nullptr)
    {
        lua_close(_l);
    }
    _l = luaL_newstate();

    // Load std libraries.
    luaL_openlibs(_l);

    // Fix lua path. https://stackoverflow.com/a/4156038
    lua_getglobal(_l, "package");
    lua_getfield(_l, -1, "path");
    lua_pop(_l, 1);
    lua_pushstring(_l, ToCString(luaPath));
    lua_setfield(_l, -2, "path");
    lua_pop(_l, 1);
}

//--------------------------------------------------------//
void InteropCore::OpenScript(String^ fn)
{
    SCOPE();

    int lstat = LUA_OK;
    int ret = 0;

    if (_l == nullptr)
    {
        EvalLuaStatus(-1, "You forgot to call InitLua().");
    }

    // Load the script into memory.
    // Pushes the compiled chunk as a lua function on top of the stack or pushes an error message.
    lstat = luaL_loadfile(_l, ToCString(fn));
    EvalLuaStatus(lstat, "Load script file failed.");

    // Execute the script to initialize it. This reports runtime syntax errors.
    // Do the protected call. Use extended version which adds a stacktrace.
    lstat = luaex_docall(_l, 0, 0);
    EvalLuaStatus(lstat, "Execute script failed.");
}


//------------------- Privates ---------------------------//

//--------------------------------------------------------//
void InteropCore::EvalLuaStatus(int lstat, String^ info)
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
        throw(gcnew LuaException(s));
    }
    else // simple
    {
        throw(gcnew LuaException(String::Format(gcnew String("{0}: {1}"), stat, info)));
    }
}

//--------------------------------------------------------//
void InteropCore::EvalLuaInteropStatus(const char* err, const char* info)
{
    if (err != NULL)
    {
        String^ s = String::Format(gcnew String("LuaInteropError: {0} [{1}]"), gcnew String(info), gcnew String(err));
        throw(gcnew LuaException(s));
    }
}

//--------------------------------------------------------//
const char* InteropCore::ToCString(String^ input)
{
    // https://learn.microsoft.com/en-us/cpp/dotnet/how-to-access-characters-in-a-system-string?view=msvc-170
    // not! const char* str4 = context->marshal_as<const char*>(input);

    // Dynamic way:
    int inlen = input->Length;
    char* buff = (char*)calloc(static_cast<size_t>(inlen) + 1, sizeof(char));
    if (buff) // shut up compiler
    {
        interior_ptr<const wchar_t> ppchar = PtrToStringChars(input);
        for (int i = 0; *ppchar != L'\0' && i < inlen; ++ppchar, i++)
        {
            int c = wctob(*ppchar);
            buff[i] = c != -1 ? c : '?';
        }

        _allocations.push_back(buff);
    }
    return buff;
}
