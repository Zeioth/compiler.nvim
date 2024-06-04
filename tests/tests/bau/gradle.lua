--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/bau/gradle.lua

local ms = 1000 -- wait time
local bau = require("compiler.bau.gradle")
local example = vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/code samples/bau/gradle"

-- Run gradlew > build.gradlew.kts > build.gradlew (first occurence by priority)
vim.api.nvim_set_current_dir(example)
bau.action("hello_world")
vim.wait(ms)
