--- Makefile bau actions

local M = {}

-- Backend - overseer tasks performed on option selected
function M.action(option)
  local overseer = require("overseer")
  local final_message = "--task finished--"
  local task = overseer.new_task({
    name = "- Make interpreter",
    strategy = { "orchestrator",
      tasks = {{ name = "- Run makefile → make " .. option ,
        cmd = "make ".. option ..                                            -- run
              " && echo make " .. option ..                                  -- echo
              " && echo \"" .. final_message .. "\"",
        components = { "default_extended" }
      },},},})
  task:start()
end

return M
