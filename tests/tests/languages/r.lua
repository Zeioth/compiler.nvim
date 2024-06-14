--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/r.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.r")
local example = require("compiler.utils").get_tests_dir("code samples/languages/r/")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep()
    vim.defer_fn(function() coroutine.resume(co) end, ms)
    coroutine.yield()
  end

  -- Run program
  vim.api.nvim_set_current_dir(example .. "run-program/")
  language.action("option2")
  sleep()

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution-nofile/")
  language.action("option3")
  sleep()

  -- Build solution
  vim.api.nvim_set_current_dir(example .. "solution/")
  language.action("option3")
  sleep()
end))
