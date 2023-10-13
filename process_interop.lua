--[[
Generate lua interop for C, C++, C#, md, html?.

VALUE_TYPE = { STRING=1, INT=2, NUMBER=3, BOOLEAN=4, TABLE=5, FUNCTION=6 }

TODOGEN enums?


]]


-- Setup environment.
-- local dc = require('dif_common')

-- local tmpl = require('pl.template')
-- local xml = require('pl.xml')
-- local pp = require('pl.path')
-- local pd = require('pl.dir')
-- local pretty = require('pl.pretty')
local utils = require('utils')

-- -- Qt C++ type mappings.
-- local simple_types = { }
-- simple_types["Int"] = "int"
-- simple_types["Double"] = "double"
-- simple_types["String"] = "QString"
-- simple_types["Bool"] = "bool"
-- simple_types["DateTime"] = "QDateTime"


--[[ .css
body{font-family:Ubuntu,sans-serif;font-size:1.1em;color:#666;background:#fff}
h1{color:#aaf;border-bottom:5px solid #aaf}
h2{color:#88d;border-bottom:3px dotted #88d}
h3{color:#66b}
h4{color:#449}
h5{color:#227}
h6{color:#005}
p:first-child{margin-top:0}
small{font-size:0.75em}
a{text-decoration:none;color:#66f}
a:hover{color:#333}
img{max-width:100%}
table{width:100%}
table code{background:transparent;padding:0}
tr{border-bottom:1px solid #999}
tr:last-child{border-bottom:5px solid #999}
th,td{font-size:1em;line-height:1.25em;margin:0;padding:0.625em 0.5em;white-space:nowrap}
th{text-align:left;text-transform:uppercase;color:#fff;background:#999}
th a{color:#fff}
pre{background:#efefef;padding:0.75em;border-radius:0.75em}
p code,ul code{padding:0.125em 0.5em;border-radius:0.5em;white-space:nowrap}
blockquote pre,blockquote code{color:#666;background:#fff}
code{background:#eee}
.center{text-align:center}
.right{text-align:right}
.content{width:768px;padding:0 20px;margin:2em auto}
.footer{font-size:0.9em}
.footer p{margin-top:1em}
]]







--[[


Get C#:
------------------
ARGTYPE string integer boolean number tableex



defs:
    _l.PushString(arg1);
    _l.PushInteger(arg2);
    _l.PushTableEx(arg3);
    _l.ToTableEx(-1);
    l!.IsInteger(1)
    l.ToInteger(1);

G: NAMESPACE
   CLASS_NAME

func(N):
    .HOST_FUNC_NAME
    .LUA_FUNC_NAME
    .WORK_FUNC*
    .DESCRIPTION
    .RET_TYPE
    .RET_DESCRIPTION
    calc: NUM_ARGS, NUM_RET
    arg(N):
        ARGN_TYPE
        ARGN_NAME
        REQUIRED


Get C:
------------------
ARGTYPE string integer boolean number tableex


defs:
    lua_pushstring(l, arg1);
    lua_pushinteger(l, arg2);
    lua_pushtableex(l, arg3);
    lua_totableex(l, -1);
    lua_isinteger(l, 1)
    lua_tointeger(l, 1)

G: NAMESPACE
   CLASS_NAME

func(N):
    .HOST_FUNC_NAME
    .LUA_FUNC_NAME
    .WORK_FUNC*
    .DESCRIPTION
    .RET_TYPE
    .RET_DESCRIPTION
    calc: NUM_ARGS, NUM_RET
    arg(N):
        ARGN_TYPE
        ARGN_NAME
        REQUIRED

]]






----------------------------------------------------------------------------------


-- Convert generic data type into language specific string.
-- Returns datatype, basetype, isobject
function gen_type(xmltype, xmlqual)
  -- Translate if possible.
  isobject = false
  
  if simple_types[xmltype] == nil then -- object or enum
    basetype = xmltype
    if xmltype:match("Enum", -4) == nil then -- else is an enum
      isobject = true
    end
  else -- is a simple type
    basetype = simple_types[xmltype]
  end
  
  if xmlqual == "array" then datatype = "QList<" .. basetype .. ">"
  else datatype = basetype
  end
 
  return datatype, basetype, isobject
end

-- Add a new simple type (enum) to our running list.
function add_enum(etype)
  simple_types[etype] = etype
end

---------------------------- Generate .h file --------------------------
function gen_h()
  local tmpl_env = { _escape='>', _parent=_G, txml=txml, bn=bn }
  
  -- Make the output file.
  content, err = tmpl.substitute(
[[
>local utils = require('utils')
>local meta = txml:child_with_name("meta")
>local enums = txml:get_elements_with_name("enum", true)
>local datas = txml:get_elements_with_name("data", true)
>local directives = txml:get_elements_with_name("directive", true)
/******************************************************************************
This file is generated from:
$(utils.clean_svn(meta.attr.url))
revision:$(utils.clean_svn(meta.attr.revision))
******************************************************************************/

#ifndef $(bn)_INCL
#define $(bn)_INCL

#include <QString>
#include <QDateTime>
#include <QList>
#include "NeptuneTypes.h"

>if #directives > 0 then
>for i,d in ipairs(directives) do
#include "$(d.attr.include).h"
>end -- directives
>end -- if directives

namespace $(meta.attr.namespace)
{
// Standard parsers and formatters
const QString DATE_TIME_FORMAT = "yyyy-MM-ddThh:mm:ss.zzz";
inline const QString FormatVal(const QDateTime& dt) { return dt.toString(DATE_TIME_FORMAT); }
inline const QString FormatVal(const QString& s) { return s; }
inline int FormatVal(const int i) { return i; }
inline double FormatVal(const double d) { return d; }
inline bool FormatVal(const bool b) { return b; }

inline bool ParseVal(const QJsonValue& v, QDateTime& dt) { bool ok = false; dt = QDateTime::fromString(v.toString(), DATE_TIME_FORMAT); return ok; }
inline bool ParseVal(const QJsonValue& v, QString& s) { bool ok = false; s = v.toString(); return ok; }
inline bool ParseVal(const QJsonValue& v, int& i) { bool ok = false; i = v.toInt(); return ok; }
inline bool ParseVal(const QJsonValue& v, double& d) { bool ok = false; d = v.toDouble(); return ok;}
inline bool ParseVal(const QJsonValue& v, bool& b) { bool ok = true; b = v.toBool(); return ok; }
    
>if #enums > 0 then
////////////////////// Enums //////////////////////
>for i,e in ipairs(enums) do
>add_enum(e.attr.name)
enum class $(e.attr.name)
{
>for i,v in ipairs(e:get_elements_with_name("value", true)) do
    $(v.attr.name) = $(v.attr.number),
>end -- enum values
};
    
QString FormatVal($(e.attr.name) v);
bool ParseVal(const QJsonValue& vin, $(e.attr.name)& v); // returns false if invalid

>end -- enums
>end -- if enums

////////////////////// Classes //////////////////////
>for i,d in ipairs(datas) do
class $(d.attr.name)
{
public:
    // Common Properties
    PROPERTY_RO(QString, TypeName)
    PROPERTY_RO(QString, Version)
    PROPERTY_RW(QList<QString>, RuntimeErrors)

public:
    // Type Properties
>for i,p in ipairs(d:get_elements_with_name("property", true)) do
>datatype, basetype, isobject = gen_type(p.attr.type, p.attr.qualifier or "")
    PROPERTY_RW($(datatype), $(p.attr.name))
>end -- properties

public:
    $(d.attr.name)(); // Constructor
    void Read(const QJsonObject& json);
    void Write(QJsonObject& json) const;
};
>end -- datas
}

#endif // guard
]], tmpl_env)

  write_output(content, err, outpath .. path_sep .. "data_" .. bn .. ".h")
end

---------------------------- Generate .cpp file --------------------------
function gen_cpp()
  local tmpl_env = { _escape='>', _parent=_G, txml=txml, bn=bn, ver=ver }

  -- Make the output file.
  content, err = tmpl.substitute(
[[
>local utils = require('utils')
>local meta = txml:child_with_name("meta")
>local enums = txml:get_elements_with_name("enum", true)
>local datas = txml:get_elements_with_name("data", true)
/******************************************************************************
This file is generated from:
$(utils.clean_svn(meta.attr.url))
revision:$(utils.clean_svn(meta.attr.revision))
******************************************************************************/

#include <QFile>
#include <QMap>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QString>
#include <QDateTime>
#include "$(bn).h"

namespace $(meta.attr.namespace)
{
>if #enums > 0 then
//////////////////////////////////// Enum handling is custom //////////////////////////////////////////
>for i,e in ipairs(enums) do
static QMap<QString, $(e.attr.name)> $(e.attr.name)_str_to_enum;
static QMap<$(e.attr.name), QString> $(e.attr.name)_enum_to_str;

static bool $(e.attr.name)_init()
{
>for i,v in ipairs(e:get_elements_with_name("value", true)) do
    $(e.attr.name)_str_to_enum["$(v.attr.name)"] = $(e.attr.name)::$(v.attr.name);   $(e.attr.name)_enum_to_str[$(e.attr.name)::$(v.attr.name)] = "$(v.attr.name)";
>end -- enum values
    return true;
}
static bool $(e.attr.name)_dummy = $(e.attr.name)_init(); // force init of luts

QString FormatVal($(e.attr.name) v)
{
>for i,v in ipairs(e:get_elements_with_name("value", true)) do
    return $(e.attr.name)_enum_to_str.value(v);
>end -- enum values
}
    
bool ParseVal(const QJsonValue& vin, $(e.attr.name)& v)
{
    v = $(e.attr.name)_str_to_enum.value(vin.toString());
    return $(e.attr.name)_str_to_enum.contains("$(e.attr.name)") ? true : false;
}
>end -- enums
>end -- if enums

>for i,d in ipairs(datas) do
///////////////////////////////////////// class /////////////////////////////////////////////////////////
$(d.attr.name)::$(d.attr.name)()
{
>for i,p in ipairs(d:get_elements_with_name("property", true)) do
>if p.attr.default ~= nil then
    m_$(p.attr.name) = $(p.attr.default); // Init with specified default.
>end
>end
    m_Version = "$(ver)";
    m_TypeName = "$(meta.attr.namespace)::$(d.attr.name)";
}

void $(d.attr.name)::Read(const QJsonObject& jin)
{
>for i,p in ipairs(d:get_elements_with_name("property", true)) do
>datatype, basetype, isobject = gen_type(p.attr.type, p.attr.qualifier or "")
    {
        QJsonValue jv = jin["$(p.attr.name)"];
>if p.attr.req ~= nil and p.attr.req == true then
        if(jv.isUndefined())
        {
            m_RuntimeErrors.append("Missing value for required property:$(p.attr.name) in:$(d.attr.name)");
        }
        else
>end
        {
>if not isobject and p.attr.qualifier == nil then -- Read simple type from json.
>if p.attr.default ~= nil then -- check for default
            m_$(p.attr.name) = $(p.attr.default);
>end
            ParseVal(jv, m_$(p.attr.name)); // simple type
>elseif not isobject and p.attr.qualifier == "array" then -- Read array of simple types from json.
            m_$(p.attr.name).clear(); // array of simple types
            QJsonArray a = jv.toArray();
            for (int i = 0; i < a.size(); i++)
            {
                QJsonValue jva = a[i];
                $(basetype) val;
                ParseVal(jva, val);
                m_$(p.attr.name).append(val);
            }
>elseif isobject and p.attr.qualifier == nil then -- Read single object from json.
            m_$(p.attr.name).Read(jv.toObject()); // single object
>elseif isobject and p.attr.qualifier == "array" then -- Read array of objects from json.
            m_$(p.attr.name).clear(); // array of objects
            QJsonArray a = jv.toArray();
            for (int i = 0; i < a.size(); i++)
            {
                QJsonObject oa = a[i].toObject();
                $(basetype) v;
                v.Read(oa);
                m_$(p.attr.name).append(v);
            }
>else
            m_RuntimeErrors.append("Deserialize unknown type:$(p.attr.name) in:$(d.attr.name)");
>end -- types
        }
    }
>end -- properties
}

void $(d.attr.name)::Write(QJsonObject& jout) const
{
>for i,p in ipairs(d:get_elements_with_name("property", true)) do
>datatype, basetype, isobject = gen_type(p.attr.type, p.attr.qualifier or "")
    {
>if not isobject and p.attr.qualifier == nil then  -- Write simple type to json string.
        jout["$(p.attr.name)"] = FormatVal(m_$(p.attr.name)); // simple type
>elseif not isobject and p.attr.qualifier == "array" then -- Write array of simple types to json string.
        QJsonArray a; // array of simple types
        foreach (const $(basetype) v, m_$(p.attr.name))
        {
            a.append(FormatVal(v));
        }
        jout["$(p.attr.name)"] = a;
>elseif isobject and p.attr.qualifier == nil then  -- Write single object to json string.
        QJsonObject o; // single object
        m_$(p.attr.name).Write(o);
        jout["$(p.attr.name)"] = o;
>elseif isobject and p.attr.qualifier == "array" then -- Write array of objects to json string.
        QJsonArray a; // array of objects
        foreach (const $(basetype) v, m_$(p.attr.name))
        {
            QJsonObject oa;
            v.Write(oa);
            a.append(oa);
        }
        jout["$(p.attr.name)"] = a;
>else
        m_RuntimeErrors.append("Serialize unknown type:$(p.attr.name) in:$(d.attr.name)");
>end -- types
    }
>end -- properties
}

>end -- datas
}
]], tmpl_env)

  write_output(content, err, outpath .. path_sep .. "data_" .. bn .. ".cc")
end

---------------------------- Generate .html files --------------------------
function gen_html()
  local meta = txml:child_with_name("meta")
  local enums = txml:get_elements_with_name("enum", true)
  local datas = txml:get_elements_with_name("data", true)
  
  -- Process enums
  for i,enum in ipairs(enums) do
    local tmpl_env = { _parent=_G, meta=meta, enum=enum, ver=ver }
    content, err = tmpl.substitute(
[[
#stop = gen_html_top(meta, enum.attr.name, ver)
$(stop)
<h1>Enum: $(enum.attr.name)</h1>
<p>$(enum.attr.desc)</p>
<p>Namespace: $(meta.attr.namespace)</p>
<h2>Values</h2>
<table>
  <tr>
    <td><b>Name</b></td>
    <td><b>Description</b></td> 
    <td><b>Number</b></td>
  </tr>
#for i,v in ipairs(enum:get_elements_with_name("value", true)) do
  <tr>
    <td>$(v.attr.name)</td>
    <td>$(v.attr.desc)</td> 
    <td>$(v.attr.number)</td>
  </tr>
#end
#sbot = gen_html_bottom() 
$(sbot)
]], tmpl_env)

    write_output(content, err, outpath .. path_sep .. "data_" .. meta.attr.namespace .. "_" .. enum.attr.name .. ".html")
  end
  
  -- Process datas.
  for i,data in ipairs(datas) do
    local tmpl_env = { _parent=_G, meta=meta, data=data, ver=ver }
    content, err = tmpl.substitute(
[[
#stop = gen_html_top(meta, data.attr.name, ver)
$(stop)
<h1>data: $(data.attr.name)</h1>
<p>$(data.attr.desc)</p>
<p>Namespace: $(meta.attr.namespace)</p>
<h2>Properties</h2>
<table>
  <tr>
    <td><b>Property</b></td>
    <td><b>Description</b></td> 
    <td><b>Type</b></td>
    <td><b>Qualifier</b></td>
    <td><b>Required</b></td>
    <td><b>Default</b></td>
  </tr>
#for i,p in ipairs(data:get_elements_with_name("property", true)) do
  <tr>
    <td>$(p.attr.name)</td>
    <td>$(p.attr.desc)</td> 
    <td>$(p.attr.type)</td>
    <td>$(p.attr.qualifier)</td>
    <td>$(p.attr.req)</td>
    <td>$(p.attr.default)</td>
  </tr>
#end
#sbot = gen_html_bottom() 
$(sbot)
]], tmpl_env)

    write_output(content, err, outpath .. path_sep .. "data_" .. meta.attr.namespace .. "_" .. data.attr.name .. ".html")
  end
end

---------------------------- Generate .json files --------------------------
function gen_json()
  local meta = txml:child_with_name("meta")
  local enums = txml:get_elements_with_name("enum", true)
  local datas = txml:get_elements_with_name("data", true)
  
 -- Process enums
  for i,enum in ipairs(enums) do
    local tmpl_env = { _parent=_G, meta=meta, enum=enum, ver=ver }
    content, err = tmpl.substitute(
[[
{
    "enum": {
      "name":"$(enum.attr.name)",
      "desc":"$(enum.attr.desc)",
      "namespace":"$(meta.attr.namespace)",
      "version": "$(ver)",
      "value": [
#for i,v in ipairs(enum:get_elements_with_name("value", true)) do
#if i ~= 1 then
         ,
#end
        { "name":"$(v.attr.name)", "desc":"$(v.attr.desc)", "number":"$(v.attr.number)" }
#end -- ipairs
      ]
    }
}
]], tmpl_env)

    write_output(content, err, outpath .. path_sep .. "data_" .. meta.attr.namespace .. "_" .. enum.attr.name .. ".json")
  end
  
  -- Process data difs.
  for i,data in ipairs(datas) do
    local tmpl_env = { _parent=_G, meta=meta, data=data, ver=ver }
    content, err = tmpl.substitute(
[[
{
    "data": {
      "name":"$(data.attr.name)",
      "desc":"$(data.attr.desc)",
      "namespace":"$(meta.attr.namespace)",
      "version": "$(ver)",
      "property": [
#for i,v in ipairs(data:get_elements_with_name("property", true)) do
#if i ~= 1 then
         ,
#end
        { "name":"$(v.attr.name)", "type":"$(v.attr.type)", "desc":"$(v.attr.desc)", "qualifier":"$(v.attr.qualifier)", "req":$(v.attr.req) }
#end
      ]
    }
}
]], tmpl_env)

    write_output(content, err, outpath .. path_sep .. "data_" .. meta.attr.namespace .. "_" .. data.attr.name .. ".json")
  end
end

---------------------------- Generate .lua file --------------------------
function gen_lua()
  local tmpl_env = { _parent=_G, txml=txml, bn=bn, ver=ver }

  -- Make the output file.
  content, err = tmpl.substitute(
[[
>local utils = require('utils')
>local meta = txml:child_with_name("meta")
>local enums = txml:get_elements_with_name("enum", true)
>local datas = txml:get_elements_with_name("data", true)
------------------------------------------------------------------------------
-- This file is generated from:
-- $(utils.clean_svn(meta.attr.url))
-- revision:$(utils.clean_svn(meta.attr.revision))
------------------------------------------------------------------------------

-- Create the namespace/module.
local ns = $(meta.attr.namespace)
local $(ns) = {}

JSON = (loadfile "JSON.lua")() -- one-time load of the routines

-- local lua_value = JSON:decode(raw_json_text)
-- local raw_json_text = JSON:encode(lua_table_or_value)
-- local pretty_json_text = JSON:encode_pretty(lua_table_or_value) -- "pretty printed" version for human readability

-- Enums
>for i,e in ipairs(enums) do
$(ns).$(e.attr.name) =
{
>for i,v in ipairs(e:get_elements_with_name("value", true)) do
  $(v.attr.name) = $(v.attr.number),
>end
}
>end

Mode = { Simple = 0, Difficult = 1 } -- "enum"
RequestDetail = { Section = "", Params = { } } -- List<ulong> Params
InfoRequest = { Command = "", Verbose = false, ReqMode = Simple, Details = { } } -- List<RequestDetail>
InfoResponse = { CompVersion = "", CompDate = "", SvnRevision = "", OtherInfo = "", Temps = { } } -- List<ulong>
-- check for required at runtime and/else default value.
--{ [1]="red", [2]="green", [3]="blue" }

return $(ns)
]], tmpl_env)

    write_output(content, err, outpath .. path_sep .. "data_" .. bn .. ".lua")
end

---------------------------- Generate .cs file - not functional yet - see C:\Dev\repos\Lua\Nebulua\gen.cs --------------------------
function gen_cs(txml)
  local tmpl_env = { _escape='>', _parent=_G, txml=txml, ver=ver }

  -- Make the output file.
  content, errors = tmpl.substitute(
[[
>local utils = require('utils')
>local meta = txml:child_with_name("meta")
>local enums = txml:get_elements_with_name("enum", true)
>local difs = txml:get_elements_with_name("dif", true)
/******************************************************************************
This file is generated from $(utils.clean_svn(meta.attr.url)):$(utils.clean_svn(meta.attr.revision))
******************************************************************************/

using System;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Serialization;
//using Newtonsoft.Json.Linq;
//using Newtonsoft.Json.Utilities;

namespace $(meta.attr.namespace)
{
    #region Enums
>for i,e in ipairs(enums) do
    public enum $(e.attr.name)
    {
>for i,v in ipairs(e:get_elements_with_name("value", true)) do
            $(v.attr.name) = $(v.attr.number),
>end
    }

>end
    #endregion

    #region Messages
>for i,m in ipairs(difs) do
    [JsonObject]
    public class $(m.attr.name)
    {
        #region Message properties
>for i,p in ipairs(m:get_elements_with_name("property", true)) do
>dtype = gen_type(p.attr.type, p.attr.qualifier or "")
        [JsonProperty]
>if dtype == DateTime then
        [JsonConverter(typeof(IsoDateTimeConverter))]
>end         
        public $(dtype) $(p.attr.name) { get; set; }
>end -- properties
        #endregion

        public $(m.attr.name)() // Constructor - init anything? default values?
        {
        }
        
        public string Serialize() // Json
        {
            return JsonConvert.SerializeObject(this); // , Formatting.Indented
        }

        public static $(m.attr.name) Deserialize(string sjson) // Json
        {
            // check for required at runtime and else default value.
            JsonConvert.DeserializeObject<$(m.attr.name)>(sjson);
        }
    };

>end -- difs
    #endregion
}
]], tmpl_env)

  return content, errors
end

-- Create generic html top stuff.
-- Returns string
function gen_html_top(meta, element, ver)
  local tmpl_env = { _parent=_G, meta=meta, element=element, ver=ver  }
  
  stop, err = tmpl.substitute(
[[
#local utils = require('utils')
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<!-- This file is generated from: -->
<!-- $(utils.clean_svn(meta.attr.url)) -->
<!-- revision:$(utils.clean_svn(meta.attr.revision)) -->
<head>
<title>API for $(element) Ver:$(ver)</title>
<link rel="stylesheet" type="text/css" href="dif_doc.css"> -- maybe just embedd this.
<meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=iso-8859-1">
</head>
<body>
]], tmpl_env)

  return stop
end

-- Create generic html bottom stuff.
-- Returns string
function gen_html_bottom()
  sbot = 
[[
</body>
</html>
]]
  return sbot
end

-------------------------------------------------
------------------ Start here -------------------
-------------------------------------------------

argsok = false
errors = nil

-- proc_data_dif -c|l|h|j infile.xml outpath version
if #arg == 4 then
  otype = arg[1]
  infile = arg[2]
  outpath = arg[3]
  ver = arg[4]
  
  pd.makepath(outpath) -- make sure it exists
  -- Read the xml
  txml = {}
  xf = io.open(infile, "r" )
  xs = xf:read("*all")
  xf:close()
  txml = xml.parse(xs)
  bn = pp.splitext(pp.basename(infile)) -- base name for include path.

  argsok = true -- if we got this far
  
  if otype == "-c" then
    gen_h()
    gen_cpp()
  elseif otype == "-l" then
    gen_lua()
  elseif otype == "-h" then
    gen_html()
  elseif otype == "-j" then
    gen_json()
  else
    argsok = false
  end
end

-- Finished
ret = ""

if errors ~= nil then
  ret = "Fail! " .. errors
end

if argsok == false then
  ret = "Fail! Args should be proc_data_dif -c|l|h|j infile outpath version"
end

return ret
