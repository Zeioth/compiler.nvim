--- Shell language actions
-- This runner is only useful for simple stuff.
-- If you need to pass parameters to your shell script, just run it on the terminal.
-- You can always create a .solution file, but this would be an overkill in most cases.

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Run program", value = "option1" },
  { text = "2 - Run solution", value = "option2" },
  { text = "3 - Run Makefile", value = "option3" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = vim.fn.expand('%:p')            -- current buffer
  local parameters = ""                               -- parameters can be overriden in .solution
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Shell interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd =                 " && time " .. entry_point ..              -- run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(vim.fn.getcwd() .. "/.solution")

      for entry, variables in pairs(config) do
        entry_point = variables.entry_point
        parameters = variables.parameters -- optional
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = "time " .. entry_point .. " " .. parameters ..               -- run
                " && echo '" .. final_message .. "'"                         -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({
        name = "- Shell interpreter", strategy = { "orchestrator",
          tasks = {
            tasks, -- Run all the programs in the solution in parallel
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
    -- Do the same as in run program, as there are no
    -- conventional entry point for shell scripts.
    local task = overseer.new_task({
      name = "- Shell interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd =                 " && time " .. entry_point ..              -- run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
    end
  elseif selected_option == "option3" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
