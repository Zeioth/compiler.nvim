--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/ruby.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.ruby")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/languages/ruby/"

-- Run
vim.api.nvim_set_current_dir(example .. "run-program/")
language.action("option2")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution-nofile/")
language.action("option3")
vim.wait(ms)

-- Build solution
vim.api.nvim_set_current_dir(example .. "solution/")
language.action("option3")
vim.wait(ms)
