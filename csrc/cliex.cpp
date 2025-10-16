#include <windows.h>
#include <wchar.h>
#include <vcclr.h>
#include <vector>

extern "C" {
#include "luaex.h"
};
#include "cliex.h"


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

// Two flavors of this: w/wo lock. It's probably best to lock on the caller's side.
#ifdef LOCK_HERE
static CRITICAL_SECTION _critsect;
Scope::Scope() { EnterCriticalSection(&_critsect); }
Scope::~Scope() { Collect(); LeaveCriticalSection(&_critsect); }
#else
Scope::Scope() {}
Scope::~Scope() { Collect(); }
#endif


//--------------------------------------------------------//
LuaException::LuaException(String^ error, String^ context) : Exception()
{
    _error = String::IsNullOrEmpty(error) ? "" : error;
    _context = String::IsNullOrEmpty(context) ? "" : context;
}

//--------------------------------------------------------//
String^ LuaException::Message::get()
{
    if (String::IsNullOrEmpty(_context))
    {
        // No trace, use info.
        return _error;
    }
    else
    {
        array<String^>^ parts = _context->Split('\n');
        return parts[0];
    }
}

//--------------------------------------------------------//
CliEx::CliEx()
{
#ifdef LOCK_HERE
    InitializeCriticalSection(&_critsect);
#endif
}

//--------------------------------------------------------//
CliEx::~CliEx()
{
    // Finished. Clean up resources and go home.
#ifdef LOCK_HERE
    DeleteCriticalSection(&_critsect);
#endif

    if (_l != nullptr)
    {
        lua_close(_l);
        _l = nullptr;
    }
}

//--------------------------------------------------------//
void CliEx::InitLua(String^ luaPath)
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
void CliEx::OpenScript(String^ fn)
{
    SCOPE();

    if (_l == nullptr)
    {
        throw(gcnew LuaException("You forgot to call InitLua()", ""));
    }

    // Load the script into memory. Pushes the compiled chunk as a lua function on top of the stack.
    LuaStatus lstat = (LuaStatus)luaL_loadfile(_l, ToCString(fn));
    EvalLuaStatus(lstat, "Load script file failed.");

    // Execute the script to initialize it. This reports runtime syntax errors. Uses extended version which adds a stacktrace.
    lstat = (LuaStatus)luaex_docall(_l, 0, 0);
    EvalLuaStatus(lstat, "Execute script failed.");
}

//--------------------------------------------------------//
void CliEx::OpenChunk(String^ code, String^ name)
{
    SCOPE();

    if (_l == nullptr)
    {
        throw(gcnew LuaException("You forgot to call InitLua()", ""));
    }

    // Load the chunk into memory. Pushes the compiled chunk as a lua function on top of the stack.
    const char* chunk = ToCString(code);
    LuaStatus lstat = (LuaStatus)luaL_loadbuffer(_l, chunk, strlen(chunk), ToCString(name));
    EvalLuaStatus(lstat, "Load chunk failed.");

    // Execute the chunk to initialize it. This reports runtime syntax errors. Uses extended version which adds a stacktrace.
    lstat = (LuaStatus)luaex_docall(_l, 0, 0);
    EvalLuaStatus(lstat, "Execute chunk failed.");
}

//--------------------------------------------------------//
void CliEx::EvalLuaStatus(LuaStatus lstat, String^ info)
{
    if (lstat >= LuaStatus::ERRRUN)
    {
        String^ context = "";
        // Maybe lua error message?
        if (_l != NULL && lua_gettop(_l) > 0)
        {
            context = gcnew String(lua_tostring(_l, -1));
            lua_pop(_l, 1);
        }
        throw(gcnew LuaException(info, gcnew String(context)));
    }
}

//--------------------------------------------------------//
const char* CliEx::ToCString(String^ input)
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
