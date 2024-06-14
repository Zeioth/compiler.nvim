--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/typescript.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.typescript")
local example = require("compiler.utils").get_tests_dir("code samples/languages/typescript/")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep()
    vim.defer_fn(function() coroutine.resume(co) end, ms)
    coroutine.yield()
  end

  -- Run
  vim.api.nvim_set_current_dir(example .. "run-program/")
  language.action("option2")
  sleep()

end))
