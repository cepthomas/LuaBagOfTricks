cmake_minimum_required(VERSION 3.5)
project(interop_gen_c)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 11)
set(LUA_SRC "C:/Program Files/Lua")
set(C_SRC "../../c")

# needs -g to debug.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-but-set-variable")

include_directories(
    ${C_SRC}
    ${LUA_SRC}/include
    )

# Source files.
add_executable(interop_gen_c
    main.c
    luainterop.c
    luainteropwork.c
    ${C_SRC}/diag.c
    ${C_SRC}/logger.c
    ${C_SRC}/luaex.c
    ${LUA_SRC}/src/lapi.c
    ${LUA_SRC}/src/lauxlib.c
    ${LUA_SRC}/src/lbaselib.c
    ${LUA_SRC}/src/lcode.c
    ${LUA_SRC}/src/lcorolib.c
    ${LUA_SRC}/src/lctype.c
    ${LUA_SRC}/src/ldblib.c
    ${LUA_SRC}/src/ldebug.c
    ${LUA_SRC}/src/ldo.c
    ${LUA_SRC}/src/ldump.c
    ${LUA_SRC}/src/lfunc.c
    ${LUA_SRC}/src/lgc.c
    ${LUA_SRC}/src/linit.c
    ${LUA_SRC}/src/liolib.c
    ${LUA_SRC}/src/llex.c
    ${LUA_SRC}/src/lmathlib.c
    ${LUA_SRC}/src/lmem.c
    ${LUA_SRC}/src/loadlib.c
    ${LUA_SRC}/src/lobject.c
    ${LUA_SRC}/src/lopcodes.c
    ${LUA_SRC}/src/loslib.c
    ${LUA_SRC}/src/lparser.c
    ${LUA_SRC}/src/lstate.c
    ${LUA_SRC}/src/lstring.c
    ${LUA_SRC}/src/lstrlib.c
    ${LUA_SRC}/src/ltable.c
    ${LUA_SRC}/src/ltablib.c
    ${LUA_SRC}/src/ltm.c
    # ${LUA_SRC}/src/lua.c
    # ${LUA_SRC}/src/luac.c
    ${LUA_SRC}/src/lundump.c
    ${LUA_SRC}/src/lutf8lib.c
    ${LUA_SRC}/src/lvm.c
    ${LUA_SRC}/src/lzio.c
    )
