cmake_minimum_required(VERSION 3.5)
project(interop_gen_c)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall")

set(LUA "C:/Lua")
set(C_SRC "../../source")

include_directories(
    ${LUA}/include
    ${C_SRC}
    )

# Source files.
add_executable(interop_gen_c
    main.c
    luainterop.c
    luainteropwork.c
    ${C_SRC}/luaex.c
    )

# Libs. 64 bit build.
target_link_libraries(interop_gen_c
    ${LUA}/Win64/lua54.dll
    )
