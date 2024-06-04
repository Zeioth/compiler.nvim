--- F# language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "Build and run program (dotnet)", value = "option1" },
  { text = "Build program (dotnet)", value = "option2" },
  { text = "Run REPL", value = "option3" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- F# compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet build & run → \".fsroj\"",
          cmd = "dotnet run" ..                                                      -- compile and run
                " && echo \"" .. final_message .. "\""                                 -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- F# compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet build → \".fsproj\"",
          cmd = "dotnet build" ..                                                    -- compile
                " && echo \"" .. final_message .. "\""                                 -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- F# REPL",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Start REPL",
          cmd = "echo 'To exit the REPL enter #q;;'" ..                              -- echo
                " ; dotnet fsi" ..                                                   -- run
                " ; echo \"" .. final_message .. "\""
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  end
end

return M
