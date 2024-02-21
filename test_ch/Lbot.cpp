#include <cstdio>
#include <cstring>
#include <fstream>
#include "pnut.h"

int main()
{
    // Run the requested tests.
    TestManager& tm = TestManager::Instance();
    std::vector<std::string> whichSuites;
    whichSuites.emplace_back("INTEROP");
    whichSuites.emplace_back("UTILS");
    std::ofstream s_ut("_test.txt", std::ofstream::out);
    tm.RunSuites(whichSuites, 'r', true, &s_ut);
    s_ut.close();

    return 0;
}
