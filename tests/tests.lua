--- This file runs all the tests to ensure all compilers are working correctly.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests.lua

-- TODOS:
-- build and run
-- solution with solution file.
-- solution without solution file.

 -- path of this script.
local dot = (debug.getinfo(1, 'S').source:sub(2):match '(.*/)')

-- Build and run
-- local build = dot .. '/tests/build&run.lua'
-- dofile(build)

-- Build
-- local build = dot .. '/tests/build.lua'
-- dofile(build)

-- Run
local build = dot .. '/tests/run.lua'
dofile(build)

-- Makefile
-- local build = dot .. '/tests/makefile.lua'
-- dofile(build)

-- Cases that require to be tested manually atm.
-- * python → Run this file.
-- * ruby   → Run this file.
-- * shell  → Run this file.
