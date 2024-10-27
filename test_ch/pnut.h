#ifndef PNUT_H
#define PNUT_H

#include <string>
#include <cstring>
#include <sstream>
#include <vector>
#include <set>
#include <iostream>
#include <cmath>
#include <time.h>
#include <stdlib.h>


/// Runtime stuff.
struct TestContext
{
    /// Current suite.
    const char* CurrentSuiteId = {};

    /// Output format:
    ///  - 'r' for human readable.
    ///  - 'x' for junit xml.
    char Format = {};

    /// Stop or try to continue.
    bool StopOnFail = false;

    /// Collected output lines.
    std::vector<std::string> OutLines = {};

    /// Collected property lines.
    std::vector<std::string> PropLines = {};

    /// Reset the context.
    void Reset();
};

/// The class that encapsulates an individual test suite.
class TestSuite
{
public:
    /// Suite ID.
    std::string ID;

    /// Suite description.
    std::string Description;

    /// Number of cases executed.
    int CaseCnt;

    /// Number of failed cases.
    int FailCnt;

    /// Constructor.
    /// @param id The ID value.
    /// @param desc The description.
    TestSuite(const std::string& id, const std::string& desc);

    /// Record a test result line into the report.
    /// @param context The TestContext struct.
    /// @param pass Test Pass or Fail.
    /// @param file Output info.
    /// @param line Output info.
    /// @param message Text describing test.
    void RecordResult(TestContext& context, bool pass, const std::string& file, unsigned int line, const std::string& message);
    
    /// Record a test property into the report.
    /// @param context The TestContext struct.
    /// @param name Property name.
    /// @param value Property value.
    void RecordProperty(TestContext& context, const std::string& name, const std::string& value);

    /// Record a verbatim text line into the report.
    /// @param context The TestContext struct.
    /// @param message Verbatim text.
    void RecordVerbatim(TestContext& context, const std::string& message);

    /// All test suite specifications must supply this execution function.
    /// @param context The TestContext struct.
    /// @return  context The TestContext struct.
    virtual int Run(TestContext& context) = 0;

    /// Compliance.
    virtual ~TestSuite();
};

/// The orchestrator of the test execution.
class TestManager
{
private:
    /// List of pointers to suites.
    std::vector<TestSuite*> _suites;

    /// Present context.
    TestContext _context;

public:
    /// Constructor.
    TestManager();

    /// Support for singleton.
    static TestManager& Instance();

    /// Add a test suite to the run. All tests are statically allocated, so we don't need to destroy them manually.
    /// @param ptc Pointer to the suite.
    void AddSuite(TestSuite* ptc);

    /// Run all selected test suites.
    /// @param which List of IDs to run.
    /// @param fmt @see TestContext.Format.
    /// @param stopOnFail @see TestContext.StopOnFail.
    /// @param where output: optional file or cout.
    void RunSuites(std::vector<std::string> which, char fmt, bool stopOnFail, std::ostream* where = &std::cout);
};


//---------------------------- Test macros ---------------------------//

/// Define a single test suite.
/// @param id The ID value.
/// @param desc The description.
#define UT_SUITE(id, desc)\
static class id##_TestSuite : public TestSuite\
{\
public:\
    id##_TestSuite() : TestSuite(#id, desc)\
    {\
        TestManager::Instance().AddSuite(this);\
    }\
    int Run(TestContext&);\
    ~id##_TestSuite(){}\
}id##_Instance;\
int id##_TestSuite::Run(TestContext& testContext)

/// Common code.
#define PASS_COMMON \
else\
{\
    std::ostringstream oss;\
    RecordResult(testContext, true,  __FILE__, __LINE__, "");\
}

/// Toggle the fatal bail out mechanism.
/// @param value True/false. value.
#define UT_STOP_ON_FAIL(value)\
{\
    testContext.StopOnFail = value;\
}\

/// Record the property name and value.
/// @param name Property name.
/// @param value Property value.
#define UT_PROPERTY(name, value)\
{\
    std::ostringstream oss;\
    oss << value;\
    RecordProperty(testContext, name, oss.str());\
}\

/// Prints the message with extra info.
/// @param message Verbatim text.
/// @param info Extra info.
#define UT_INFO(message, info)\
{\
    if(testContext.Format == 'r')\
    {\
        std::ostringstream oss;\
        oss << message << " " << info << std::endl;\
        RecordVerbatim(testContext, oss.str());\
    }\
}

/// Checks whether the given condition is true.
/// @param condition True?
#define UT_TRUE(condition)\
{\
    if(!(condition))\
    {\
        std::ostringstream oss;\
        oss << "[" << #condition << "] should be true";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the given condition is false.
/// @param condition False?
#define UT_FALSE(condition)\
{\
    if(condition)\
    {\
        std::ostringstream oss;\
        oss << "[" << #condition << "] should be false";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the value is NULL.
/// @param value NULL?
#define UT_NULL(value)\
{\
    if((value) != NULL)\
    {\
        std::ostringstream oss;\
        oss << "[" << value << "] should be null";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the value is not NULL.
/// @param value NULL?
#define UT_NOT_NULL(value)\
{\
    if((value) == NULL)\
    {\
        std::ostringstream oss;\
        oss << "[value] should not be null";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first argument is equal to the second.
/// @param value
/// @param expected
#define UT_EQUAL(value, expected)\
{\
    if((value) != (expected))\
    {\
        std::ostringstream oss;\
        oss << "[" << value << "] should be " << "[" << expected << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first argument is not equal to the second.
/// @param value
/// @param unexpected
#define UT_NOT_EQUAL(value, unexpected)\
{\
    if((value) == (unexpected))\
    {\
        std::ostringstream oss;\
        oss << "[" << value << "] should not be " << "[" << unexpected << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first argument is less than the second.
/// @param value1
/// @param value2
#define UT_LESS(value1, value2)\
{\
    if((value1) >= (value2))\
    {\
        std::ostringstream oss;\
        oss << "[" << value1 << "] should be less than " << "[" << value2 << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first argument is less than or equal to the second.
/// @param value1
/// @param value2
#define UT_LESS_OR_EQUAL(value1, value2)\
{\
    if((value1) > (value2))\
    {\
        std::ostringstream oss;\
        oss << "[" << value1 << "] should be less than or equal to " << "[" << value2 << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first argument is greater than the second.
/// @param value1
/// @param value2
#define UT_GREATER(value1, value2)\
{\
    if((value1) <= (value2))\
    {\
        std::ostringstream oss;\
        oss << "[" << value1 << "] should be greater than " << "[" << value2 << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first argument is greater than or equal to the second.
/// @param value1
/// @param value2
#define UT_GREATER_OR_EQUAL(value1, value2)\
{\
    if((value1) < (value2))\
    {\
        std::ostringstream oss;\
        oss << "[" << value1 << "] should be greater than or equal to " << "[" << value2 << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first argument is within the given tolerance from
/// the second argument. This is useful for comparing floating point values.
/// @param value1
/// @param value2
/// @param tolerance
#define UT_CLOSE(value1, value2, tolerance)\
{\
    if(fabs((value1)-(value2)) > tolerance)\
    {\
        std::ostringstream oss;\
        oss << "[" << value1 << "] should be within " << tolerance << " of " << "[" << value2 << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first string is equal to the second.
/// @param value
/// @param expected
#define UT_STR_EQUAL(value, expected)\
{\
    if(value == NULL || expected == NULL || strcmp(value, expected) != 0)\
    {\
        std::ostringstream oss;\
        oss << "[" << value << "] should be " << "[" << expected << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the first string is not equal to the second.
/// @param value
/// @param unexpected
#define UT_STR_NOT_EQUAL(value, unexpected)\
{\
    if(value == NULL || unexpected == NULL || strcmp(value, unexpected) == 0)\
    {\
        std::ostringstream oss;\
        oss << "[" << value << "] should not be " << "[" << unexpected << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the string is empty, otherwise prints the contents.
/// @param value
#define UT_STR_EMPTY(value)\
{\
    if(value == NULL || strlen(value) > 0)\
    {\
        std::ostringstream oss;\
        oss << "[" << value << "] should be empty";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

/// Checks whether the string contains the phrase.
/// @param value
/// @param phrase
#define UT_STR_CONTAINS(value, phrase)\
{\
    if(value == NULL || phrase == NULL || (strstr(value, phrase) == NULL))\
    {\
        std::ostringstream oss;\
        oss << "[" << value << "] does not contain " << "[" << phrase << "]";\
        RecordResult(testContext, false,  __FILE__, __LINE__, oss.str());\
        if (testContext.StopOnFail) return 1;\
    }\
    PASS_COMMON\
}

#endif
