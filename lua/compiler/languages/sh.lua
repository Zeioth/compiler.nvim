--- Shell language actions
-- This runner is only useful for simple stuff.
-- If you need to pass arguments to your shell script, just run it on the terminal.
-- You can always create a .solution file, but this would be an overkill in most cases.

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Run this file", value = "option1" },
  { text = "2 - Run solution",  value = "option2" },
  { text = "3 - Run Makefile",  value = "option3" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = vim.fn.expand('%:p')            -- current buffer
  local arguments = ""                               -- arguments can be overriden in .solution
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Shell interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
          cmd = entry_point ..                                               -- run
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution.toml") then
      local config = utils.parseConfigFile(utils.osPath(vim.fn.getcwd() .. "/.solution.toml"))

      for entry, variables in pairs(config) do
        entry_point = utils.osPath(variables.entry_point)
        arguments = variables.arguments or "" -- optional
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = arguments .. arguments == "" or " " .. entry_point ..      -- run
                " && echo " .. entry_point ..                                -- echo
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
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.sh")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.osPath(entry_point)
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = entry_point ..                                               -- run
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"                         -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Shell interpreter", strategy = { "orchestrator", tasks = tasks }
      })

      task:start()
      vim.cmd("OverseerOpen")
    end
  elseif selected_option == "option3" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
