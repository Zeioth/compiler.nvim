--- Visual basic dotnet language actions

local M = {}

--- Frontend - options displayed on telescope
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
        tasks = {{ name = "- Dotnet build & run → \"Program.vbproj\"",
          cmd = "dotnet run" ..                                              -- compile and run
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Visual basic dotnet compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Dotnet build → \"Program.vbproj\"",
          cmd = "dotnet build" ..                                            -- compile
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
  end
end

return M
