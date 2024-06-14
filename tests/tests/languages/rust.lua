--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/languages/rust.lua

local ms = 1000 -- wait time
local language = require("compiler.languages.rust")
local example = require("compiler.utils").get_tests_dir("code samples/languages/rust/")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep()
    vim.defer_fn(function() coroutine.resume(co) end, ms)
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
  sleep()

  -- Build solution (without .solution file)
  vim.api.nvim_set_current_dir(example .. "solution-nofile/")
  language.action("option4")
  sleep()

  -- Build solution
  vim.api.nvim_set_current_dir(example .. "solution/")
  language.action("option4")
  sleep()

  -- Cargo build and run
  vim.api.nvim_set_current_dir(example .. "cargo-build-and-run/")
  language.action("option5")
  sleep()

  -- Cargo build
  vim.api.nvim_set_current_dir(example .. "cargo-build/")
  language.action("option6")
  sleep()

  -- Cargo run
  vim.api.nvim_set_current_dir(example .. "cargo-run/")
  language.action("option7")
  sleep()

  -- Cargo build --all and run
  vim.api.nvim_set_current_dir(example .. "cargo-build-all-and-run/")
  language.action("option8")
  sleep()

  -- Cargo build --all
  vim.api.nvim_set_current_dir(example .. "cargo-build-all/")
  language.action("option9")
  sleep()
end))
