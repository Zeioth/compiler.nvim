--- asm actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Build and run program", value = "option1" },
  { text = "2 - Build program",         value = "option2" },
  { text = "3 - Run program",           value = "option3" },
  { text = "4 - Run Makefile",          value = "option4" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = utils.osPath(vim.fn.getcwd() .. "/main.asm")   -- working_directory/main.asm
  local output_dir = utils.osPath(vim.fn.getcwd() .. "/bin/")        -- working_directory/bin/
  local output = utils.osPath(vim.fn.getcwd() .. "/bin/program")     -- working_directory/bin/program
  local parameters = ""                                              -- parameters can be overriden in .solution
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Assembly compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. output .. ".o && rm -f " .. output ..                     -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && nasm -f elf64 " .. entry_point .. " -o " .. output .. ".o " .. parameters .. -- compile
                " && ld " .. output .. ".o -o " .. output .. " " ..                   -- link
                " && time " .. output ..                                              -- run
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Assembly compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output .. ".o && rm -f " .. output ..                     -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && nasm -f elf64 " .. entry_point .. " -o " .. output .. ".o " .. parameters .. -- compile
                " && ld " .. output .. ".o -o " .. output .. " " ..                   -- link
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Assembly compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
          cmd = "time " .. output ..                                                  -- run
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(
        os_path(vim.fn.getcwd() .. "/.solution"))
      local executable

      for entry, variables in pairs(config) do
        executable = utils.osPath(variables.executable)
        if executable then goto continue end
        entry_point = utils.osPath(variables.entry_point)
        output = utils.osPath(variables.output)
        output_dir = utils.osPath(output:match("^(.-[/\\])[^/\\]*$"))
        parameters = variables.parameters or parameters -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output .. ".o && rm -f " .. output ..                     -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && nasm -f elf64 " .. entry_point .. " -o " .. output .. ".o " .. parameters .. -- compile
                " && ld " .. output .. ".o -o " .. output .. " " ..                   -- link
                " && echo '" .. final_message .. "'"                                  -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      if executable then
        task = { "shell", name = "- Run program → " .. executable,
          cmd = "time " .. executable ..                                     -- run
                " && echo '" .. final_message .. "'"                         -- echo
        }
      else
        task = {}
      end

      task = overseer.new_task({
        name = "- Assembly compiler", strategy = { "orchestrator",
          tasks = {
            tasks, -- Build all the programs in the solution in parallel
            task   -- Then run the solution executable
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.c")

      for _, ep in ipairs(entry_points) do
        ep = utils.osPath(ep)
        output_dir = utils.osPath(ep:match("^(.-[/\\])[^/\\]*$") .. "/bin") -- entry_point/bin
        output = utils.osPath(output_dir .. "/program")                     -- entry_point/bin/program
        task = { "shell", name = "- Build program → " .. ep,
          cmd = "rm -f " .. output .. ".o && rm -f " .. output ..            -- clean
                " && mkdir -p " .. output_dir ..                             -- mkdir
                " && nasm -f elf64 " .. ep .. " -o " .. output .. ".o " .. parameters .. -- compile
                " && ld " .. output .. ".o -o " .. output .. " " ..          -- link
                " && echo '" .. final_message .. "'"                         -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created secuentially
        name = "- Assembly compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end
  elseif selected_option == "option5" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
