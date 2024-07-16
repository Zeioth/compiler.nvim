--- This file runs all the tests to ensure all compilers are working correctly.
--- @usage :luafile ~/.local/share/nvim/lazy/compiler.nvim/tests/tests.lua

-- NOTE: These tests are meant to run in a Ryzen 5900x or upper.
--       If your CPU is slower, you will have to increase the wait time
--       in this file, and in every individual test.

local tests_dir = require("compiler.utils").get_tests_dir("tests/languages/")

coroutine.resume(coroutine.create(function()
  local co = coroutine.running()
  local function sleep(_ms)
    vim.defer_fn(function() coroutine.resume(co) end, _ms)
    coroutine.yield()
  end

  dofile(tests_dir .. 'asm.lua')
  sleep(10000)
  dofile(tests_dir .. 'c.lua')
  sleep(10000)
  dofile(tests_dir .. 'cpp.lua')
  sleep(10000)
  dofile(tests_dir .. 'cs.lua')
  sleep(10000)
  dofile(tests_dir .. 'dart.lua')
  sleep(15000)
  dofile(tests_dir .. 'elixir.lua')
  sleep(3000)
  dofile(tests_dir .. 'fortran.lua')
  sleep(5000)
  dofile(tests_dir .. 'fsharp.lua')
  sleep(5000)
  dofile(tests_dir .. 'gleam.lua')
  sleep(5000)
  dofile(tests_dir .. 'go.lua')
  sleep(25000)
  dofile(tests_dir .. 'java.lua')
  sleep(25000)
  dofile(tests_dir .. 'javascript.lua')
  sleep(5000)
  dofile(tests_dir .. 'kotlin.lua')
  sleep(25000)
  dofile(tests_dir .. 'lua.lua')
  sleep(5000)
  dofile(tests_dir .. 'make.lua')
  sleep(1000)
  dofile(tests_dir .. 'perl.lua')
  sleep(5000)
  dofile(tests_dir .. 'python.lua')
  sleep(25000)
  dofile(tests_dir .. 'r.lua')
  sleep(5000)
  dofile(tests_dir .. 'ruby.lua')
  sleep(5000)
  dofile(tests_dir .. 'rust.lua')
  sleep(25000)
  dofile(tests_dir .. 'sh.lua')
  sleep(5000)
  dofile(tests_dir .. 'swift.lua')
  sleep(10000)
  dofile(tests_dir .. 'typescript.lua')
  sleep(5000)
  dofile(tests_dir .. 'vb.lua')
  sleep(5000)
  dofile(tests_dir .. 'zig.lua')

  -- Cases that require to be tested manually atm.
  -- * python                          → Run this file.
  -- * ruby                            → Run this file.
  -- * shell                           → Run this file.
  -- * elixir                          → Run this file.
  -- * fortran                         → Run this file.
  -- * fsharp                          → Run this file.
  -- * r                               → Run this file.
  -- * typescript                      → Run this file.
  -- * javascript                      → Run this file.
  -- * dart                            → Run this file.
  -- * python/r/elixir/F#/kotlin/swift → REPL
  -- * flutter                         → Run program (its a loop).
  --
end))
