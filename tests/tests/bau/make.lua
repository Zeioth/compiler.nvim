--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/bau/make.lua

local ms = 1000 -- wait time
local bau = require("compiler.bau.make")
local example = require("compiler.utils").get_tests_dir("code samples/bau/make")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep(_ms)
    if not _ms then _ms = ms end
    vim.defer_fn(function() coroutine.resume(co) end, _ms)
    coroutine.yield()
  end

  -- Run makefile
  vim.api.nvim_set_current_dir(example)
  bau.action("hello_world")
  sleep()
end))
