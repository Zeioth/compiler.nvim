--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/fsharp.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.fsharp")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/fsharp/"

-- Build and run dotnet
vim.api.nvim_set_current_dir(example .. "build-and-run-dotnet/")
language.action("option2")
vim.wait(ms)

-- Build dotnet
vim.api.nvim_set_current_dir(example .. "build-dotnet/")
language.action("option3")
vim.wait(ms)
