--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/bau/nodejs.lua

local ms = 1000 -- wait time
local bau = require("compiler.bau.nodejs")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/bau/nodejs/"

-- Run nodejs javascript project
vim.api.nvim_set_current_dir(example .. "javascript-app")
bau.action("npm install && npm start")
vim.wait(ms)

-- Run nodejs typescript project
vim.api.nvim_set_current_dir(example .. "typescript-app")
bau.action("npm install && npm start")
vim.wait(ms)
