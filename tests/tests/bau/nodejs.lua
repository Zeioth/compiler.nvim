--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/bau/nodejs.lua

local bau = require("compiler.bau.nodejs")

-- Run nodejs javascript project
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/bau/nodejs/javascript-app"
vim.api.nvim_set_current_dir(example)
bau.action("npm install")
vim.wait(10000) -- wait time
bau.action("npm start")
vim.wait(1000) -- wait time

-- Run nodejs typescript project
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples/bau/nodejs/typescript-app"
vim.api.nvim_set_current_dir(example)
bau.action("npm install")
vim.wait(10000) -- wait time
bau.action("npm start")
vim.wait(1000) -- wait time
