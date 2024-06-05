--- package.json bau actions

local M = {}

-- Backend - overseer tasks performed on option selected
function M.action(option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  -- Run command
  local task = overseer.new_task({
    name = "- Node.js package manager",
    strategy = { "orchestrator",
      tasks = {{ "shell", name = "- Run script → " .. option,
        cmd = option ..                                                      -- run script
              " && echo \"" .. option .. "\"" ..                             -- echo
              " && echo \"" .. final_message .. "\""
      },},},})
  task:start()
  vim.cmd("OverseerOpen")
end

return M
