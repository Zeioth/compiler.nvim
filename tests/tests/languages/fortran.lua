--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/fortran.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.fortran")
local example = require("compiler.utils").get_tests_dir("code samples/languages/fortran/")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep()
    vim.defer_fn(function() coroutine.resume(co) end, ms)
    coroutine.yield()
  end

  -- Build and run
  vim.api.nvim_set_current_dir(example .. "fpm-build-and-run/")
  language.action("option2")
  sleep()

  -- Build
  vim.api.nvim_set_current_dir(example .. "fpm-build/")
  language.action("option3")
  sleep()

  -- Run
  vim.api.nvim_set_current_dir(example .. "fpm-build/")
  language.action("option4")
  sleep()
end))
