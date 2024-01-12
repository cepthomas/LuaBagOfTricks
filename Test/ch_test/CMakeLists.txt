cmake_minimum_required(VERSION 3.5)
project(interop_gen_c)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 11)

set(LUA "C:/Lua")
set(C_SRC "../../c")

# needs -g to debug.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-but-set-variable")

include_directories(
    ${C_SRC}
    ${LUA}/include
    )

# Source files.
add_executable(interop_gen_c
    main.c
    luainterop.c
    luainteropwork.c
    ${C_SRC}/private/diag.c
    ${C_SRC}/private/logger.c
    ${C_SRC}/private/luaex.c
    )

# Libs. 64 bit build.
target_link_libraries(nebulua
    ${LUA}/Win64/lua54.dll
    )
