--- This file runs all the tests to ensure all compilers are working correctly.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests.lua

 -- path of this script.
local dot = (debug.getinfo(1, 'S').source:sub(2):match '(.*/)')


-- Build and run
local build = dot .. '/tests/build&run.lua'
dofile(build)
vim.wait(1000)

-- Build
local build = dot .. '/tests/build.lua'
dofile(build)
vim.wait(1000)

-- Run
local build = dot .. '/tests/run.lua'
dofile(build)
vim.wait(1000)

-- Makefile
local build = dot .. '/tests/makefile.lua'
dofile(build)
vim.wait(1000)

-- Solution (no file)
local build = dot .. '/tests/solution-no-file.lua'
dofile(build)
vim.wait(1000)

-- Solution (with file)
local build = dot .. '/tests/solution.lua'
dofile(build)

-- Cases that require to be tested manually atm.
-- * python → Run this file.
-- * ruby   → Run this file.
-- * shell  → Run this file.
