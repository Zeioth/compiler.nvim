--- Visual basic dotnet language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Build and run program (dotnet)", value = "option1" },
  { text = "2 - Build program (dotnet)", value = "option2" },
  { text = "3 - Run Makefile", value = "option3" }
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
          cmd = "dotnet run" ..                                                      -- compile and run
                " && echo '" .. final_message .. "'"                                 -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Visual basic dotnet compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Dotnet build → .vbproj",
          cmd = "dotnet build" ..                                                    -- compile
                " && echo '" .. final_message .. "'"                                 -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
