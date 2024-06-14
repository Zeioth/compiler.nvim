--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/python.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.python")
local example

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep(_ms)
    if not _ms then _ms = ms end
    vim.defer_fn(function() coroutine.resume(co) end, _ms)
    coroutine.yield()
  end

  -- ============================= INTERPRETED ==================================
  example = require("compiler.utils").get_tests_dir("code samples/languages/python/interpreted/")

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

  -- ============================= MACHINE CODE =================================
  example = require("compiler.utils").get_tests_dir("code samples/languages/python/machine-code/")

  -- Build and run
  vim.api.nvim_set_current_dir(example .. "build-and-run/")
  language.action("option4")
  sleep()

  -- Build
  vim.api.nvim_set_current_dir(example .. "build/")
  language.action("option5")
  sleep(6000)

  -- Run
  language.action("option6")
  sleep()

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution-nofile/")
  language.action("option7")
  sleep()

  -- Build solution
  vim.api.nvim_set_current_dir(example .. "solution/")
  language.action("option7")
  sleep()

  -- =============================== BYTECODE ===================================
  example = require("compiler.utils").get_tests_dir("code samples/languages/python/bytecode/")

  -- Build and run
  vim.api.nvim_set_current_dir(example .. "build-and-run/")
  language.action("option8")
  sleep()

  -- Build
  vim.api.nvim_set_current_dir(example .. "build/")
  language.action("option9")
  sleep(6000)

  -- Run
  vim.wait(ms)
  language.action("option10")
  sleep()

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution-nofile/")
  language.action("option11")
  sleep()

  -- Build solution
  vim.api.nvim_set_current_dir(example .. "solution/")
  language.action("option11")
  sleep()
end))
