--- This test run "Run Makefile" (which is the same for all languages).
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/makefile.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.make")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples"

-- Run makefile
vim.api.nvim_set_current_dir(example)
language.action("option1")
vim.wait(ms)
