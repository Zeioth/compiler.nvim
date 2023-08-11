--- Perl language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Run this file", value = "option1" },
  { text = "2 - Run program",   value = "option2" },
  { text = "3 - Run solution",  value = "option3" },
  { text = "4 - Run Makefile",  value = "option4" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = vim.fn.expand('%:p')                                  -- current file
  local entry_point = utils.osPath(vim.fn.getcwd() .. "/main.pl")            -- working_directory/main.pl
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Perl interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run this file → " .. current_file,
          cmd =  "perl " .. current_file ..                                  -- run (interpreted)
                " && echo " .. current_file ..                               -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Perl interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = "perl " .. entry_point ..                                  -- run (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(utils.osPath(vim.fn.getcwd() .. "/.solution"))

      for entry, variables in pairs(config) do
        entry_point = utils.osPath(variables.entry_point)
        arguments = variables.arguments or "" -- optional
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = "perl " .. arguments .. " " .. entry_point ..               -- run (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({
        name = "- Perl interpreter", strategy = { "orchestrator",
          tasks = {
            tasks, -- Run all the programs in the solution in parallel
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.pl")
      arguments = "" -- optional
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.osPath(entry_point)
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "perl " .. arguments .. " " .. entry_point ..               -- run (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Perl interpreter", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end
  elseif selected_option == "option4" then
    require("compiler.languages.make").run_makefile()                        -- run
  end

end

return M
