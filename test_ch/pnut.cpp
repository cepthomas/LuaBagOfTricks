
#include "pnut.h"

//-------------------------- TestSuite ------------------------------//

//---------------------------------------------------------------//
void TestContext::Reset()
{
    CurrentSuiteId = "???";
    Format = 'r';
    OutLines.clear();
    PropLines.clear();
}

//-------------------------- TestSuite ------------------------------//

//---------------------------------------------------------------//
TestSuite::TestSuite(const std::string& id, const std::string& desc)
{
    ID = id;
    Description = desc;
    CaseCnt = 0;
    FailCnt = 0;
}

//---------------------------------------------------------------//
void TestSuite::RecordResult(TestContext& context, bool pass, const std::string& file, unsigned int line, const std::string& message)
{
    std::ostringstream sstr;
    CaseCnt++;

    if(pass)
    {
        if(context.Format == 'x')
        {
            sstr << "        <testcase name=\"" << context.CurrentSuiteId << "." << CaseCnt << "\" classname=\"" << context.CurrentSuiteId << "\" />" << std::endl;
        }
    }
    else
    {
        FailCnt++;

        if(context.Format == 'x')
        {
            sstr << "        <testcase name=\"" << context.CurrentSuiteId << "." << CaseCnt << "\" classname=\"" << context.CurrentSuiteId << "\">" << std::endl;
            sstr << "            <failure message=\"" << file << ":" << line << " " << message << "\"></failure>" << std::endl;
            sstr << "        </testcase>" << std::endl;
        }
        else // readable
        {
            /// Output the failure string with file/line.
            sstr << "! " << file << ":" << line << " " << context.CurrentSuiteId << "." << CaseCnt << " " << message << std::endl;
        }
    }

    context.OutLines.push_back(sstr.str());
}
    
//---------------------------------------------------------------//
void TestSuite::RecordProperty(TestContext& context, const std::string& name, const std::string& value)
{
    std::ostringstream pstr;
    if(context.Format == 'x')
    {
        pstr << "<property name=\"" << name << "\" value=\"" << value << "\" />";
        context.PropLines.push_back(pstr.str());
    }
    else // readable
    {
        pstr << "Property " << name << ":" << value << std::endl;
        context.OutLines.push_back(pstr.str());
    }
}

//---------------------------------------------------------------//
void TestSuite::RecordVerbatim(TestContext& context, const std::string& message)
{
    context.OutLines.push_back(message);
}

//---------------------------------------------------------------//
TestSuite::~TestSuite()
{

}

//-------------------------- TestSuite ------------------------------//

//---------------------------------------------------------------//
TestManager::TestManager()
{
    _context.Reset();
}

//---------------------------------------------------------------//
TestManager& TestManager::Instance()
{
    static TestManager self;
    return self;
}

//---------------------------------------------------------------//
void TestManager::AddSuite(TestSuite* ptc)
{
    _suites.push_back(ptc);
}

//---------------------------------------------------------------//
void TestManager::RunSuites(std::vector<std::string> which, char fmt, bool stopOnFail, std::ostream* where)
{
    _context.Reset();
    _context.Format = fmt;
    _context.StopOnFail = stopOnFail;
    int caseCnt = 0;
    int failCnt = 0;
    int fatalCnt = 0;
    time_t tStart = time(NULL);

    // Run through to execute suites.
    for(std::vector<TestSuite*>::iterator iter = _suites.begin(); iter != _suites.end(); ++iter)
    {
        // Is this suite requested?
        bool newSuite = (which.size() == 0);
        if(!newSuite)
        {
            for(std::vector<std::string>::iterator itRun = which.begin(); itRun != which.end(); ++itRun)
            {
                int n = (int)(*iter)->ID.find(*itRun);
                if(n == 0) // beginning of name
                {
                    newSuite = true;
                }
            }
        }

        if(newSuite)
        {
            /// New suite. Reset states.
            _context.CurrentSuiteId = (*iter)->ID.c_str();
            _context.PropLines.clear();

            /// Document the start of the suite.
            if(_context.Format == 'x')
            {
                std::ostringstream oss;
                oss << "    <testsuite name=" << (*iter)->ID << ">" << std::endl;
                (*iter)->RecordVerbatim(_context, oss.str());
            }
            else // readable
            {
                std::ostringstream oss;
                oss << std::endl << "Test Suite " << (*iter)->ID << ": " << (*iter)->Description << std::endl;
                (*iter)->RecordVerbatim(_context, oss.str());
            }

            /// Run the suite.
            int res = (*iter)->Run(_context);
            if (res != 0)
            {
                // The suite failed fatally.
                (*iter)->RecordVerbatim(_context, "^^^^^^^^^^^^^^^^ FATAL");
                fatalCnt++;
            }

            /// Completed the suite, update the counts.
            failCnt += (*iter)->FailCnt;
            caseCnt += (*iter)->CaseCnt;

            if(_context.Format == 'x')
            {
                // Any properties?
                if(_context.PropLines.size() > 0)
                {
                    std::ostringstream oss1;
                    oss1 << "        <properties>" << std::endl;
                    (*iter)->RecordVerbatim(_context, oss1.str());

                    for(std::vector<std::string>::iterator piter = _context.PropLines.begin(); piter != _context.PropLines.end(); ++piter)
                    {
                        std::ostringstream ossp;
                        ossp << "            " << *piter << std::endl;
                        (*iter)->RecordVerbatim(_context, ossp.str());
                    }

                    std::ostringstream oss2;
                    oss2 << "        </properties>" << std::endl;
                    (*iter)->RecordVerbatim(_context, oss2.str());
                }

                std::ostringstream oss;
                oss << "    </testsuite>" << std::endl;
                (*iter)->RecordVerbatim(_context, oss.str());
            }
        }
    }

    /// Finished the test run, prepare the summary.
    time_t tEnd = time(NULL);
    char sStartTime[32];
    strftime(sStartTime, 32, "%Y-%m-%d %H:%M:%S", localtime(&tStart));
    time_t dur = tEnd - tStart;

    if(_context.Format == 'x')
    {
        *where << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" << std::endl;
        *where << "<testsuites" << " tests=" << caseCnt << " failures=" << failCnt << " fatal=" << fatalCnt << " time=" << dur << ">" << std::endl;
    }
    else // readable
    {
        *where << "#------------------------------------------------------------------" << std::endl;
        *where << "# Unit Test Report" << std::endl;
        *where << "# Start Time: " << sStartTime << std::endl;
        *where << "# Duration: " << dur << std::endl;
        *where << "# Cases Run: " << caseCnt << std::endl;
        *where << "# Cases Failed: " << failCnt << std::endl;
        *where << "# Fatal Suites: " << fatalCnt << std::endl;
        *where << "# Test Result: " << ((failCnt > 0) || (fatalCnt > 0) ? "Fail" : "Pass") << std::endl;
        *where << "#--------------------------------------------------------------------" << std::endl;
    }

    /// Write out the test result lines.
    for(std::vector<std::string>::iterator iter = _context.OutLines.begin(); iter != _context.OutLines.end(); ++iter)
    {
        *where << *iter;
    }

    if(_context.Format == 'x')
    {
        *where << "</testsuites>" << std::endl;
    }
}
