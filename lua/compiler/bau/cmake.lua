--- CMakeLists.txt bau actions

local M = {}

-- Backend - overseer tasks performed on option selected
function M.action(option)
  local overseer = require("overseer")
  local final_message = "--task finished--"
  local task = overseer.new_task({
    name = "- CMake interpreter",
    strategy = { "orchestrator",
      tasks = {{ "shell", name = "- Run CMake → cmake -S . -B build &&  cmake --build build --target " .. option,
        cmd = "rm -rf ./build" ..
              " && mkdir -p ./build" ..
              " && cmake -S . -B build" ..                                   -- Generate build files in a 'build' directory
              " && cmake --build build --target " .. option ..               -- Build the specified target from the 'build' directory
              " && echo cmake " .. option ..                                 -- echo
              " && echo '" .. final_message .. "'"
      },},},})
  task:start()
  vim.cmd("OverseerOpen")
end

return M
