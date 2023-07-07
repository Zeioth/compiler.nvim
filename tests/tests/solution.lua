--- This test run "Build solution" for all languages when a .solution file is not present.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/solution-file.lua

local ms = 1000 -- ms
local language = nil

-- Set as working dir → 'compiler.nvim/tests/examples'.
vim.api.nvim_set_current_dir(
  vim.fn.stdpath "data" .. "/lazy/compiler.nvim/tests/examples")


-- test c
-- language = require("compiler.languages.c")
-- language.action("option2")
-- vim.wait(ms)
-- c++
-- language = require("compiler.languages.cpp")
-- language.action("option2")
-- vim.wait(ms)
-- cs
-- language = require("compiler.languages.cs")
-- language.action("option2")
-- vim.wait(ms)
-- java
-- language = require("compiler.languages.java")
-- language.action("option2")
-- vim.wait(ms)
-- asm
-- language = require("compiler.languages.asm")
-- language.action("option2")
-- vim.wait(ms)
-- python
-- language = require("compiler.languages.python")
-- language.action("option2")
-- vim.wait(ms)
-- ruby
-- language = require("compiler.languages.ruby")
-- language.action("option2")
-- vim.wait(ms)
-- rust
-- language = require("compiler.languages.rust")
-- language.action("option2")
-- vim.wait(ms)
-- shell
language = require("compiler.languages.shell")
language.action("option1")
vim.wait(ms)
-- make
-- language = require("compiler.languages.make")
-- language.action("option1")
