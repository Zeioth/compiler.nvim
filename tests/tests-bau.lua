--- This file runs all the tests to ensure all bau are working correctly.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests-bau.lua

local tests_dir = require("compiler.utils").plugin_dir_append("tests/bau/")
local ms = 1000 -- wait time

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep(_ms)
    if not _ms then _ms = ms end
    vim.defer_fn(function() coroutine.resume(co) end, _ms)
    coroutine.yield()
  end

  dofile(tests_dir .. 'make.lua')
  sleep()
  dofile(tests_dir .. 'cmake.lua')
  sleep()
  dofile(tests_dir .. 'gradle.lua')
  sleep()
  dofile(tests_dir .. 'nodejs.lua')
  sleep()
  dofile(tests_dir .. 'meson.lua')
  sleep()
  dofile(tests_dir .. 'nodejs.lua')
end))
