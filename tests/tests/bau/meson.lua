--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/bau/meson.lua

local ms = 1000 -- wait time
local bau = require("compiler.bau.meson")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/bau/meson"

-- Run meson.build
vim.api.nvim_set_current_dir(example)
bau.action("hello_world")
vim.wait(ms)
