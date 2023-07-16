--- This test run "Build program" for all languages.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/python.lua

local ms = 5000 -- wait time
local language = require("compiler.languages.python")
local example

-- ============================= INTERPRETED ==================================
example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/python/interpreted/"

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "run-program/")
language.action("option2")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution-nofile/")
language.action("option3")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution/")
language.action("option3")
vim.wait(ms)

-- ============================= MACHINE CODE =================================
example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/python/machine-code/"

-- Build and run
vim.api.nvim_set_current_dir(example .. "build-and-run/")
language.action("option4")
vim.wait(ms)

-- Build
vim.api.nvim_set_current_dir(example .. "build/")
language.action("option5")
vim.wait(ms)

-- Run
language.action("option6")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution-nofile/")
language.action("option7")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution/")
language.action("option7")
vim.wait(ms)

-- =============================== BYTECODE ===================================
example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/python/bytecode/"

-- Build and run
vim.api.nvim_set_current_dir(example .. "build-and-run/")
language.action("option8")
vim.wait(ms)

-- Build
vim.api.nvim_set_current_dir(example .. "build/")
language.action("option9")
vim.wait(ms)

-- Run
vim.wait(ms)
language.action("option10")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution-nofile/")
language.action("option11")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution/")
language.action("option11")
vim.wait(ms)
