--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/fortran.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.fortran")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/code samples/languages/fortran/"

-- Build and run
vim.api.nvim_set_current_dir(example .. "fpm-build-and-run/")
language.action("option2")
vim.wait(ms)

-- Build
vim.api.nvim_set_current_dir(example .. "fpm-build/")
language.action("option3")
vim.wait(ms)
