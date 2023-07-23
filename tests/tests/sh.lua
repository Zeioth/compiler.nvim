--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/sh.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.sh")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/sh/"


-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution-nofile/")
language.action("option2")
vim.wait(ms)

-- Build solution (without .solution file)
vim.api.nvim_set_current_dir(example .. "solution/")
language.action("option2")
vim.wait(ms)
