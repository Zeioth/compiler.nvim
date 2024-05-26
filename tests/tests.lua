--- This file runs all the tests to ensure all compilers are working correctly.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests.lua

-- path of this script → tests
local tests_dir = (debug.getinfo(1, 'S').source:sub(2):match '(.*/)') .. "/tests/languages/"

dofile(tests_dir .. 'asm.lua')
dofile(tests_dir .. 'c.lua')
dofile(tests_dir .. 'cpp.lua')
dofile(tests_dir .. 'cs.lua')
dofile(tests_dir .. 'dart.lua')
dofile(tests_dir .. 'elixir.lua')
dofile(tests_dir .. 'fortran.lua')
dofile(tests_dir .. 'fsharp.lua')
dofile(tests_dir .. 'go.lua')
dofile(tests_dir .. 'java.lua')
dofile(tests_dir .. 'javascript.lua')
dofile(tests_dir .. 'kotlin.lua')
dofile(tests_dir .. 'lua.lua')
dofile(tests_dir .. 'make.lua')
dofile(tests_dir .. 'perl.lua')
dofile(tests_dir .. 'python.lua')
dofile(tests_dir .. 'r.lua')
dofile(tests_dir .. 'ruby.lua')
dofile(tests_dir .. 'rust.lua')
dofile(tests_dir .. 'sh.lua')
dofile(tests_dir .. 'swift.lua')
dofile(tests_dir .. 'typescript.lua')
dofile(tests_dir .. 'vb.lua')
dofile(tests_dir .. 'zig.lua')

-- Cases that require to be tested manually atm.
-- * python                          → Run this file.
-- * ruby                            → Run this file.
-- * shell                           → Run this file.
-- * elixir                          → Run this file.
-- * fortran                         → Run this file.
-- * fsharp                          → Run this file.
-- * r                               → Run this file.
-- * typescript                      → Run this file.
-- * javascript                      → Run this file.
-- * dart                            → Run this file.
-- * python/r/elixir/F#/kotlin/swift → REPL
-- * flutter                         → Run program (its a loop).
--
