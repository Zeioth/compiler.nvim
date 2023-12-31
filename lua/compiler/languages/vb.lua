--- Visual basic dotnet language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "Build and run program (dotnet)", value = "option1" },
  { text = "Build program (dotnet)", value = "option2" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Visual basic dotnet compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet build & run → .vbproj",
          cmd = "dotnet run" ..                                              -- compile and run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Visual basic dotnet compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet build → .vbproj",
          cmd = "dotnet build" ..                                            -- compile
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  end
end

return M
