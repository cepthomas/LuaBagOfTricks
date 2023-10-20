--[[
Unit tests for interop processor. TODO1
]]


ut = require("utils")

-- Create the namespace/module.
local M = {}

-----------------------------------------------------------------------------
function M.setup(pn)
    -- pn.UT_INFO("setup()!!!")
end

-----------------------------------------------------------------------------
function M.teardown(pn)
    -- pn.UT_INFO("teardown()!!!")
end

-----------------------------------------------------------------------------
function M.suite_interop(pn)
    pn.UT_INFO("Test all functions in process_interop.lua")

    a = 1
    b = 2
    pn.UT_EQUAL(a, b)

end

-----------------------------------------------------------------------------
-- Return the module.
return M



--[[
/////////////////////////////// The tests //////////////////////////////////
TEST(DataDifUnitTestLevel1, DataDifToCppSerializeTest)
{
    RecordProperty("Component_Name", "DataDifToCpp.lua");
    RecordProperty("Test_Description", "Test generation of json from objects.");
    RecordProperty("Source", "$URL: http://ocdusrow3rndd3:8686/NEPTUNE_SANDBOX/trunk/Source/dif/unit_test/DataDifTest.cc $");
    RecordProperty("Test_Method", "Excercise some stuff.");
    RecordProperty("Requirements", "???");
    RecordProperty("Objective", "???");
    RecordProperty("Setup", "???");
    RecordProperty("Dependency", "");
    RecordProperty("Test_Step", "1. fdfd 2. booboo");

    // Do something with classes created by the build tests steps.
    pgmns::Program pgm;

    // Simple properties
    pgm.setPatientId("Patient uno");
    pgm.setSampleId(1110444);
    pgm.setStatus(testns::StatusType_Enum::Ready);
    pgm.Complete().setMSecsSinceEpoch(15000000000);

    // List of enums.
    QList<testns::StatusType_Enum> statuses;
    statuses.append(testns::StatusType_Enum::Done);
    statuses.append(testns::StatusType_Enum::Ready);
    statuses.append(testns::StatusType_Enum::InProcess);
    pgm.setStatusList(statuses);

    // Single object using getters.
    pgm.TestUno().setStatus(testns::StatusType_Enum::InProcess);
    pgm.TestUno().When().setMSecsSinceEpoch(10000000000);
    pgm.TestUno().Params().append(12.34);
    pgm.TestUno().Params().append(999999.0001);
    pgm.TestUno().Params().append(0.0000012);

    // Array of objects using setters and getters.
    testns::ProgramTest test1;
    test1.setStatus(testns::StatusType_Enum::Done);
    QDateTime dt1;
    dt1.setMSecsSinceEpoch(20000000000);
    test1.setWhen(dt1);
    QList<double> vals1;
    vals1.append(7777.777707);
    vals1.append(1.00000009);
    test1.setParams(vals1);
    pgm.TestList().append(test1);

    testns::ProgramTest test2;
    test2.setStatus(testns::StatusType_Enum::Done);
    QDateTime dt2;
    dt2.setMSecsSinceEpoch(30000000000);
    test2.setWhen(dt2);
    test2.Params().append(8008);
    test2.Params().append(000.0003);
    pgm.TestList().append(test2);

    // Convert to json.
    QJsonObject jo;
    pgm.Write(jo);

    QJsonDocument jodoc(jo);
    //QByteArray bytes = jodoc.toJson();
    QString sjson = jodoc.toJson(QJsonDocument::JsonFormat::Compact);

    //printf(qPrintable(sjson));
    EXPECT_STREQ(NEPTUNE_VERSION, qPrintable(pgm.Version()));

    EXPECT_STREQ("{\"Complete\":\"1970-06-23T10:40:00.000\",\"PatientId\":\"Patient uno\",\"SampleId\":1110444,\"Status\":\"Ready\",\"StatusList\":[\"Done\",\"Ready\",\"InProcess\"],\"TestList\":[{\"Flag\":true,\"Params\":[7777.7777070000002,1.0000000899999999],\"Status\":\"Done\",\"When\":\"1970-08-20T07:33:20.000\"},{\"Flag\":true,\"Params\":[8008,0.00029999999999999997],\"Status\":\"Done\",\"When\":\"1970-12-14T00:20:00.000\"}],\"TestUno\":{\"Flag\":true,\"Params\":[12.34,999999.00009999995,1.1999999999999999e-06],\"Status\":\"InProcess\",\"When\":\"1970-04-26T13:46:40.000\"}}", qPrintable(sjson));
}

TEST(DataDifUnitTestLevel1, DataDifToCppDeserializeTest)
{
    RecordProperty("Component_Name", "DataDifToCpp.lua");
    RecordProperty("Test_Description", "Test generation of objects from json.");
    RecordProperty("Source", "$URL: http://ocdusrow3rndd3:8686/NEPTUNE_SANDBOX/trunk/Source/dif/unit_test/DataDifTest.cc $");
    RecordProperty("Test_Method", "Excercise some stuff.");
    RecordProperty("Requirements", "???");
    RecordProperty("Objective", "???");
    RecordProperty("Setup", "???");
    RecordProperty("Dependency", "");
    RecordProperty("Test_Step", "1. fdfd 2. booboo");

    QByteArray sin("{\"Complete\":\"1975-06-23T10:40:00.000\",\"PatientId\":\"Patient dos\",\"SampleId\":1199944,\"Status\":\"Ready\",\"StatusList\":[\"InProcess\",\"Ready\",\"InProcess\"],\"TestList\":[{\"Flag\":true,\"Params\":[99.999,1.00000007777],\"Status\":\"Done\",\"When\":\"1970-09-20T07:33:20.123\"},{\"Flag\":false,\"Params\":[8008,0.00029999999999999997],\"Status\":\"InProcess\",\"When\":\"1980-12-14T00:20:00.000\"}],\"TestUno\":{\"Flag\":true,\"Params\":[999999.00009999995,12.34,1.1999999999999999e-06],\"Status\":\"Done\",\"When\":\"1970-04-26T19:46:44.555\"}}");

    // Unpack the payload into a json object.
    QJsonParseError err;
    QJsonDocument jdoc = QJsonDocument::fromJson(sin, &err);
    EXPECT_EQ(false, jdoc.isNull());

    pgmns::Program pgm;
    pgm.Read(jdoc.object());

    EXPECT_STREQ(NEPTUNE_VERSION, qPrintable(pgm.Version()));

    EXPECT_STREQ("Patient dos", qPrintable(pgm.PatientId()));
    //printf("%i:%i:%i:%d\n", pgm.Status(), pgm.SampleId())
    EXPECT_EQ(testns::StatusType_Enum::Ready, pgm.Status());
    EXPECT_EQ(1199944, pgm.SampleId());
    EXPECT_EQ(3, pgm.StatusList().count());

    EXPECT_EQ(2, pgm.TestList().count());
    EXPECT_EQ(true, pgm.TestList()[0].Flag());
    EXPECT_EQ(1.00000007777, pgm.TestList()[0].Params()[1]);

    EXPECT_EQ(false, pgm.TestList()[1].Flag());
    EXPECT_EQ(12, pgm.TestList()[1].When().date().month());
}
]]