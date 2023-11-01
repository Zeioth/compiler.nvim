--- CMakeLists.txt bau actions

local M = {}


-- Backend - overseer tasks performed on option selected
function M.action(option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  -- Global: CMAKE_BUILD_DIR
  local build_dir = vim.api.nvim_get_var("CMAKE_BUILD_DIR") or "./build"
  vim.api.nvim_set_var("CMAKE_BUILD_DIR", build_dir)

  -- Global: CMAKE_BUILD_TYPE
  local build_type = vim.api.nvim_get_var("CMAKE_BUILD_TYPE") or "Release"
  vim.api.nvim_set_var("CMAKE_BUILD_TYPE", build_type)

  -- Run command
  local cmd_build = "cmake -S . -B " .. build_dir .. " -DCMAKE_BUILD_TYPE=" .. build_type
  local cmd_target = "cmake --build " .. build_dir .. " --target " .. option
  local task = overseer.new_task({
    name = "- CMake interpreter",
    strategy = { "orchestrator",
      tasks = {{ "shell", name = "- Run CMake → " .. option,
        cmd = "mkdir -p " .. build_dir ..
              " && " .. cmd_build ..                                         -- Build to 'build' directory.
              " && " .. cmd_target ..                                        -- Build target from the 'build' directory.
              " && echo '" .. cmd_build .. " && " .. cmd_target .. "'" ..    -- echo
              " && echo '" .. final_message .. "'"
      },},},})
  task:start()
  vim.cmd("OverseerOpen")
end

return M
