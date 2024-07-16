--- Shell language actions
-- This runner is only useful for simple stuff.
-- If you need to pass arguments to your shell script, just run it on the terminal.
-- You can always create a .solution file, but this would be an overkill in most cases.

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Run solution",  value = "option2" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = utils.os_path(vim.fn.expand('%:p'), true)                  -- current buffer
  local arguments = ""                                                           -- arguments can be overriden in .solution
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Shell interpreter",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run program → " .. entry_point,
          cmd = entry_point ..                                                   -- run
                " && echo " .. entry_point ..                                    -- echo
                " && echo \"" .. final_message .. "\"",                          -- echo
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local entry_points
    local task = {}
    local tasks = {}
    local executables = {}

    -- if .solution file exists in working dir
    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point, true)
        arguments = variables.arguments or "" -- optional
        task = { name = "- Run program → " .. entry_point,
          cmd = (arguments == "" and "" or arguments .. " ") .. entry_point  ..  -- run
                " && echo " .. entry_point ..                                    -- echo
                " && echo \"" .. final_message .. "\"",                          -- echo
          components = { "default_extended" }
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          executable = utils.os_path(executable, true)
          task = { name = "- Run program → " .. executable,
            cmd = executable ..                                                  -- run
                  " && echo " .. executable ..                                   -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          }
          table.insert(executables, task) -- store all the executables we've created
        end
      end

      task = overseer.new_task({
        name = "- Shell interpreter", strategy = { "orchestrator",
          tasks = {
            tasks,        -- Run all the programs in the solution in parallel
            executables   -- Then run the solution executable(s)
          }}})
      task:start()

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.sh")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point, true)
        task = { name = "- Run program → " .. entry_point,
          cmd = entry_point ..                                                   -- run
                " && echo " .. entry_point ..                                    -- echo
                " && echo \"" .. final_message .. "\"",                          -- echo
          components = { "default_extended" }
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Shell interpreter", strategy = { "orchestrator", tasks = tasks }
      })

      task:start()
    end
  end
end

return M
