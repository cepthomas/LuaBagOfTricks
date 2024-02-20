-- Script with syntax errors to detect on loadfile.

local gen = require("gen_lib") -- lua-C api

bad_statement_oops

ts = gen.get_timestamp()

print(ts)
