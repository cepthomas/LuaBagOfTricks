#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "luaex.h"
#include "interop.h"

int main(int argc, char* argv[])
{
    // int ret = 0;

    // if(argc == 2)
    // {
    //     if(exec_Init() == RS_PASS)
    //     {
    //         // Blocks forever.
    //         if(exec_Run(argv[1]) != RS_PASS)
    //         {
    //             // Bad thing happened.
    //             ret = 3;
    //             printf("!!! exec_run() failed\n");
    //         }
    //     }
    //     else
    //     {
    //         ret = 2;
    //         printf("!!! exec_init() failed\n");
    //     }
    // }
    // else
    // {
    //     ret = 1;
    //     printf("!!! invalid args\n");
    // }


    return 0;
}

double interop_LuaCallHost_DoWork(int arg1, const char* arg2)
{
  return 7777.7;
}
