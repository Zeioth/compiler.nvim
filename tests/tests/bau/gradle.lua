--- This test file run all supported cases of use.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests/bau/gradle.lua

local ms = 1000 -- wait time
local bau = require("compiler.bau.gradle")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep(_ms)
    if not _ms then _ms = ms end
    vim.defer_fn(function() coroutine.resume(co) end, _ms)
    coroutine.yield()
  end

  -- Run gradlew > build.gradlew.kts > build.gradlew (first occurence by priority)
  local example = require("compiler.utils").get_tests_dir("code samples/bau/gradle/parse-file")
  vim.api.nvim_set_current_dir(example)
  bau.action("hello_world")
  sleep()

  -- Run gradlew > build.gradlew.kts > build.gradlew (first occurence by priority)
  example = require("compiler.utils").get_tests_dir("code samples/bau/gradle/parse-cmd")
  vim.api.nvim_set_current_dir(example)
  bau.action("bootRun")
  sleep()
end))
