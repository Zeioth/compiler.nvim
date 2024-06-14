--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/go.lua

local ms = 6000 -- wait time
local language = require("compiler.languages.go")
local example = require("compiler.utils").get_tests_dir("code samples/languages/go/")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep(_ms)
    if not _ms then _ms = ms end
    vim.defer_fn(function() coroutine.resume(co) end, _ms)
    coroutine.yield()
  end

  -- Build and run
  vim.api.nvim_set_current_dir(example .. "build-and-run/")
  language.action("option1")
  sleep()

  -- Build
  vim.api.nvim_set_current_dir(example .. "build/")
  language.action("option2")
  sleep()

  -- Run
  language.action("option3")
  sleep(1000)

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution-nofile/")
  language.action("option4")
  sleep()

  -- Build solution
  vim.api.nvim_set_current_dir(example .. "solution/")
  language.action("option4")
  sleep()
end))
