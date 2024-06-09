--- CMakeLists.txt bau actions

local M = {}

-- Backend - overseer tasks performed on option selected
function M.action(option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  -- Global: CMAKE_BUILD_DIR
  local success, build_dir = pcall(vim.api.nvim_get_var, 'CMAKE_BUILD_DIR')
  if not success or build_dir == "" then build_dir = './build' end

  -- Global: CMAKE_BUILD_TYPE
  local success, build_type = pcall(vim.api.nvim_get_var, 'CMAKE_BUILD_TYPE')
  if not success or build_type == "" then build_type = '""' end

  -- Global: CMAKE_CLEAN_FIRST
  local clean_first_arg = ""
  local _, clean_first = pcall(vim.api.nvim_get_var, 'CMAKE_CLEAN_FIRST')
  if clean_first == "true" then clean_first_arg = "--clean-first" end

  -- Run command
  local cmd_build = "cmake -S . -B \"" .. build_dir .. "\" -DCMAKE_BUILD_TYPE=" .. build_type
  local cmd_target = "cmake --build \"" .. build_dir .. "\" --target " .. option .. " " .. clean_first_arg
  local task = overseer.new_task({
    name = "- CMake interpreter",
    strategy = { "orchestrator",
      tasks = {{ name = "- Run CMake → " .. option,
        cmd = "mkdir -p \"" .. build_dir .. "\"" ..
              " && " .. cmd_build ..                                         -- Build to 'build' directory.
              " && " .. cmd_target ..                                        -- Build target from the 'build' directory.
              " && echo '" .. cmd_build .. " && " .. cmd_target .. "'" ..    -- echo
              " && echo \"" .. final_message .. "\"",
        components = { "default_extended" }
      },},},})
  task:start()
end

return M
