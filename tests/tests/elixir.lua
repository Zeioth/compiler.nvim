--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/elixir.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.elixir")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/elixir/"

-- Build and run
vim.api.nvim_set_current_dir(example .. "build-and-run/")
language.action("option2")
vim.wait(ms)
