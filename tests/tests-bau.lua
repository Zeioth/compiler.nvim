--- This file runs all the tests to ensure all bau are working correctly.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests-bau.lua

-- path of this script → tests
local tests_dir = (debug.getinfo(1, 'S').source:sub(2):match '(.*/)') .. "/tests/bau/"

dofile(tests_dir .. 'make.lua')
dofile(tests_dir .. 'cmake.lua')
dofile(tests_dir .. 'gradle.lua')
