--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/dart.lua
--- NOTE: You must initialize the flutter dir with 'flutter create'.

local ms =  1000 -- wait time
local language = require("compiler.languages.dart")
local example

-- ============================= INTERPRETED ==================================
example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/code samples/languages/dart/interpreted/"

-- Run program
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

-- ============================= MACHINE CODE =================================
example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/code samples/languages/dart/machine-code/"

-- Build and run
vim.api.nvim_set_current_dir(example .. "build-and-run/")
language.action("option4")
vim.wait(ms)

-- Build
vim.api.nvim_set_current_dir(example .. "build/")
language.action("option5")
vim.wait(3000)

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

-- =============================== FLUTTER ===================================
example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/code samples/languages/dart/fluttr/"
vim.api.nvim_set_current_dir(example)

-- We don't test run program (flutter because it is a loop)
-- language.action("option8")
-- vim.wait(ms)

-- Build for linux (flutter)
language.action("option9")
vim.wait(ms)

-- Build for android (flutter)
language.action("option10")
vim.wait(ms)

-- Build for ios (flutter) → This will fail if no on ios
-- language.action("option11")
-- vim.wait(ms)

-- Build for web (flutter)
language.action("option12")
vim.wait(ms)

-- =============================== OTHER ===================================
example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/code samples/languages/dart/transpiled/"

-- Transpile to javascript
vim.api.nvim_set_current_dir(example .. "to-javascript/")
language.action("option13")
vim.wait(ms)
