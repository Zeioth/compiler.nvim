--- This file runs all the tests to ensure all compilers are working correctly.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests.lua

 -- path of this script → tests
local tests_dir = (debug.getinfo(1, 'S').source:sub(2):match '(.*/)') .. "/tests/"

dofile(tests_dir .. 'c.lua')
dofile(tests_dir .. 'cpp.lua')
dofile(tests_dir .. 'cs.lua')
dofile(tests_dir .. 'rust.lua')
dofile(tests_dir .. 'asm.lua')
dofile(tests_dir .. 'java.lua')
dofile(tests_dir .. 'python.lua')
dofile(tests_dir .. 'ruby.lua')
dofile(tests_dir .. 'sh.lua')
dofile(tests_dir .. 'make.lua')

-- Cases that require to be tested manually atm.
-- * python → Run this file.
-- * ruby   → Run this file.
-- * shell  → Run this file.
