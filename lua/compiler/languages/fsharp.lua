--- F# language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Dotnet run this file on REPL", value = "option1" },
  { text = "", value = "separator" },
  { text = "2 - Dotnet build and run", value = "option2" },
  { text = "3 - Dotnet build", value = "option3" },
  { text = "", value = "separator" },
  { text = "4 - Run Makefile", value = "option4" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local current_file = vim.fn.expand('%:p')                                  -- current file
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- F# compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet run on REPL → " .. current_file,
          cmd = "  echo 'To exit the REPL enter #q;;'" ..                            -- echo
                " ; dotnet fsi " .. current_file ..                                  -- run (interpreted)
                " ; echo " .. current_file ..                                        -- echo
                " ; echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- F# compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet build & run → .fsroj",
          cmd = "dotnet run" ..                                                      -- compile and run
                " && echo '" .. final_message .. "'"                                 -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- F# compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet build → .fsproj",
          cmd = "dotnet build" ..                                                    -- compile
                " && echo '" .. final_message .. "'"                                 -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
