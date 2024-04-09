--- Dioxus bau actions

local M = {}

-- Backend - overseer tasks performed on option selected
function M.action(_)
  local overseer = require("overseer")
  local final_message = "--task finished--"
  local task = overseer.new_task({
    name = "- Dioxus runner",
    strategy = { "orchestrator",
      tasks = {{ "shell", name = "- Build and run Dioxus ",
        cmd = "dx serve --hot-reload" ..                               -- run
              " && echo '" .. final_message .. "'"
      },},},})
  task:start()
  vim.cmd("OverseerOpen")
end

return M
