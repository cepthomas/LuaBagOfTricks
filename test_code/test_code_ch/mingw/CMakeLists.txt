cmake_minimum_required(VERSION 3.5)
project(interop_gen_c)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall")

# set(LBOT "C:/Dev/repos/Lua/LuaBagOfTricks")

include_directories(
    ../
    ../../../source_code
    # Lua headers.
    ../lua_lib/include
    )

# Source files.
add_executable(interop_gen_c
    main.c
    ../luainterop.c
    ../../../source_code/luaex.c
    ../../../source_code/luautils.c
    )

# message (${PROJECT_SOURCE_DIR})

# Libs. 64 bit build.
target_link_libraries(interop_gen_c
    ${PROJECT_SOURCE_DIR}/../lua_lib/lua54.dll
    )
