--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/dart.lua
--- NOTE: You must initialize the flutter dir with 'flutter create'.

local ms =  1000 -- wait time
local language = require("compiler.languages.dart")
local example

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep(_ms)
    if not _ms then _ms = ms end
    vim.defer_fn(function() coroutine.resume(co) end, _ms)
    coroutine.yield()
  end

  -- ============================= INTERPRETED ================================
  example = require("compiler.utils").get_tests_dir("code samples/languages/dart/interpreted/")

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

  -- ============================= MACHINE CODE ===============================
  example = require("compiler.utils").get_tests_dir("code samples/languages/dart/machine-code/")

  -- Build and run
  vim.api.nvim_set_current_dir(example .. "build-and-run/")
  language.action("option4")
  sleep()

  -- Build
  vim.api.nvim_set_current_dir(example .. "build/")
  language.action("option5")
  sleep(3000)

  -- Run
  language.action("option6")
  sleep()

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution-nofile/")
  language.action("option7")
  sleep()

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution/")
  language.action("option7")
  sleep()

  -- =============================== FLUTTER ==================================
  example = require("compiler.utils").get_tests_dir("code samples/languages/dart/fluttr/")
  vim.api.nvim_set_current_dir(example)

  -- We don't test run program (flutter because it is a loop)
  -- language.action("option8")
  -- vim.wait(ms)

  -- Build for linux (flutter)
  language.action("option9")
  sleep()

  -- Build for android (flutter)
  language.action("option10")
  sleep()

  -- Build for ios (flutter) → This will fail if no on ios
  -- language.action("option11")
  sleep()

  -- Build for web (flutter)
  language.action("option12")
  sleep()

  -- =============================== OTHER ====================================
  example = require("compiler.utils").get_tests_dir("code samples/languages/dart/transpiled/")

  -- Transpile to javascript
  vim.api.nvim_set_current_dir(example .. "to-javascript/")
  language.action("option13")
  sleep()
end))
