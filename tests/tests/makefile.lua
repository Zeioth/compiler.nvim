--- This test run "Run Makefile" (which is the same for all languages).
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/makefile.lua

local ms = 1000 -- ms
local language = nil

-- Set as working dir → 'compiler.nvim/tests/examples'.
vim.api.nvim_set_current_dir(
  vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples")

-- make
language = require("compiler.languages.make")
language.action("option1")
vim.wait(ms)
