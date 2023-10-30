--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/bau/make.lua

local ms = 1000 -- wait time
local language = require("compiler.bau.cmake")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/bau/cmake"

-- Run CMakeLists.txt
vim.api.nvim_set_current_dir(example)
language.action("hello_world")
vim.wait(ms)
