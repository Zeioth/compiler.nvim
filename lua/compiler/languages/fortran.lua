--- Fortran language actions

local M = {}

-- Frontend  - options displayed on telescope
M.options = {
  { text = "Build and run program", value = "option1" },
  { text = "Build program", value = "option2" },
  { text = "Run program", value = "option3" },
  { text = "Build solution", value = "option4" },
  { text = "", value = "separator" },
  { text = "fpm build and run", value = "option5" },
  { text = "fpm build", value = "option6" },
  { text = "fpm run", value = "option7" },
}

-- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/main.f90")          -- working_directory/main.f90
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")               -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/program")            -- working_directory/bin/program
  local arguments = "-D warnings -g"                                         -- arguments can be overriden in .solution
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. output ..  " || true" ..                                       -- clean
                " && mkdir -p " .. output_dir ..                                           -- mkdir
                " && gfortran " .. entry_point .. " -o " .. output .. " " .. arguments ..  -- compile
                " && " .. output ..                                                        -- run
                " && echo " .. entry_point ..                                              -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..  " || true" ..                                       -- clean
                " && mkdir -p " .. output_dir ..                                           -- mkdir
                " && gfortran " .. entry_point .. " -o " .. output .. " " .. arguments ..  -- compile
                " && echo " .. entry_point ..                                              -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = output ..                                                  -- run
                " && echo " .. output ..                                     -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
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
        entry_point = utils.os_path(variables.entry_point)
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..  " || true" ..                                    -- clean
                " && mkdir -p " .. output_dir ..                                        -- mkdir
                " && gfortran " .. entry_point .. " -o " .. output .. " " .. arguments ..  -- compile
                " && echo " .. entry_point ..                                           -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          task = { "shell", name = "- Run program → " .. executable,
            cmd = executable ..                                                         -- run
                  " && echo " .. executable ..                                          -- echo
                  " && echo '" .. final_message .. "'"
          }
          table.insert(executables, task) -- store all the executables we've created
        end
      end

      task = overseer.new_task({
        name = "- Fortran compiler", strategy = { "orchestrator",
          tasks = {
            tasks,        -- Build all the programs in the solution in parallel
            executables   -- Then run the solution executable(s)
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.f90")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")      -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                                  -- entry_point/bin/program
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..  " || true" ..                                      -- clean
                " && mkdir -p " .. output_dir ..                                          -- mkdir
                " && gfortran " .. entry_point .. " -o " .. output .. " " .. arguments .. -- compile
                " && echo " .. entry_point ..                                             -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Fortran compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end
  elseif selected_option == "option5" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- fpm build & run → " .. "fpm.toml",
          cmd = "fpm build " ..                                                       -- compile
                " && fpm run" ..                                                      --run
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option6" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- fpm build → " .. "fpm.toml",
          cmd = "fpm build " ..                                                       -- compile
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option7" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- fpm run → " .. "fpm.toml",
          cmd = "fpm run " ..                                                        -- run
                " && echo '" .. final_message .. "'"                                 -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
   end
end

return M

