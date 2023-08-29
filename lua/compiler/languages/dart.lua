--- Dart/Flutter language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1  - Run this file (interpreted)", value = "option1" },
  { text = "2  - Run program (interpreted)", value = "option2" },
  { text = "3  - Build solution (interpreted)", value = "option3" },
  { text = "", value = "separator" },
  { text = "4  - Build and run program (machine code)", value = "option4" },
  { text = "5  - Build program (machine code)", value = "option5" },
  { text = "6  - Run program (machine code)", value = "option6" },
  { text = "7  - Build solution (machine code)", value = "option7" },
  { text = "", value = "separator" },
  { text = "8  - Run program (flutter)", value = "option8" },
  { text = "9  - Build for linux (flutter)", value = "option9" },
  { text = "10 - Build for android (flutter)", value = "option10" },
  { text = "11 - Build for ios (flutter)", value = "option11" },
  { text = "12 - Build for web (flutter)", value = "option12" },
  { text = "", value = "separator" },
  { text = "13 - Transpile program to javascript", value = "option13" },
  { text = "14 - Run Makefile", value = "option14" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = vim.fn.expand('%:p')                                  -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/lib/main.dart")     -- working_directory/lib/main.dart
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")               -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/main")               -- working_directory/bin/main
  local final_message = "--task finished--"


  --=========================== INTERPRETED =================================--
  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Dart interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run this file → " .. current_file,
          cmd = "dart " .. current_file ..                                           -- run
                " && echo " .. current_file ..                                       -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Dart interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
          cmd = "dart " .. entry_point ..                                           -- run (interpreted)
                " && echo " .. entry_point ..                                       -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
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
        local arguments = variables.arguments or "" -- optional
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = "dart " .. arguments .. " " .. entry_point ..                        -- run (interpreted)
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          task = { "shell", name = "- Run program → " .. executable,
            cmd = executable ..                                                      -- run
                  " && echo " .. executable ..                                       -- echo
                  " && echo '" .. final_message .. "'"
          }
          table.insert(executables, task) -- store all the executables we've created
        end
      end

      task = overseer.new_task({
        name = "- Dart interpreter", strategy = { "orchestrator",
          tasks = {
            tasks,        -- Build all the programs in the solution in parallel
            executables   -- Then run the solution executable(s)
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.dart")
      local arguments = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "dart " .. arguments .. " " .. entry_point ..                -- run (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Dart interpreter", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end












  --========================== MACHINE CODE =================================--
  elseif selected_option == "option4" then
    local arguments = "" -- optional
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. output ..  " || true" ..                                 -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && dart compile exe " .. entry_point .. " -o " .. output .. " " .. arguments .. -- compile
                " && " .. output ..                                                  -- run
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")  elseif selected_option == "option5" then
    local arguments = "" -- optional
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..  " || true" ..                                 -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && dart compile exe " .. entry_point .. " -o " .. output .. " " .. arguments .. -- compile
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")  elseif selected_option == "option6" then
    local arguments = "" -- optional
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
          cmd = output ..                                                            -- run
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option7" then
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
        local arguments = variables.arguments or "" -- optional
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = "rm -f " .. output ..  " || true" ..                                 -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && dart compile exe " .. entry_point .. " -o " .. output .. " " .. arguments .. -- compile
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          task = { "shell", name = "- Run program → " .. executable,
            cmd = executable ..                                              -- run
                  " && echo " .. executable ..                               -- echo
                  " && echo '" .. final_message .. "'"
          }
          table.insert(executables, task) -- store all the executables we've created
        end
      end

      task = overseer.new_task({
        name = "- Dart interpreter", strategy = { "orchestrator",
          tasks = {
            tasks,        -- Build all the programs in the solution in parallel
            executables   -- Then run the solution executable(s)
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.dart")
      local arguments = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "../bin")  -- entry_point/../bin
        output = utils.os_path(output_dir .. "/main")                                    -- entry_point/bin/main
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd ="rm -f " .. output ..  " || true" ..                                  -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && dart compile exe " .. entry_point .. " -o " .. output .. " " .. arguments .. -- compile
                " && echo " .. entry_point ..                                        -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Dart compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end








  --===================== MACHINE CODE (FLUTTER) ============================--
  elseif selected_option == "option8" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Flutter run",
          cmd = "flutter run " ..                                                         -- run
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option9" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Flutter build (linux)",
          cmd = "flutter build linux" ..                                                  -- compile for linux
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option10" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Flutter build (android)",
          cmd = "flutter build apk" ..                                                  -- compile for android
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")  elseif selected_option == "option11" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Flutter build (ios)",
          cmd = "flutter build ios" ..                                                  -- compile for ios
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")  elseif selected_option == "option12" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Flutter build (web)",
          cmd = "flutter build web" ..                                                  -- compile for web
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")












  --= ================== TRANSPILE (TO JAVASCRIPT) ==========================--
  elseif selected_option == "option13" then
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Transpile to javascript → " .. entry_point,
          cmd = "dart compile js -o" .. output_dir .. "/js/ "  .. entry_point ..                               -- transpile to js
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")












  --=============================== MAKE ====================================--
  elseif selected_option == "option14" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
