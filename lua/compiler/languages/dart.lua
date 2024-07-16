--- Dart/Flutter language actions

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Run this file (interpreted)", value = "option1" },
  { text = "Run program (interpreted)", value = "option2" },
  { text = "Build solution (interpreted)", value = "option3" },
  { text = "", value = "separator" },
  { text = "Build and run program (machine code)", value = "option4" },
  { text = "Build program (machine code)", value = "option5" },
  { text = "Run program (machine code)", value = "option6" },
  { text = "Build solution (machine code)", value = "option7" },
  { text = "", value = "separator" },
  { text = "Run program (flutter)", value = "option8" },
  { text = "Build for linux (flutter)", value = "option9" },
  { text = "Build for android (flutter)", value = "option10" },
  { text = "Build for ios (flutter)", value = "option11" },
  { text = "Build for web (flutter)", value = "option12" },
  { text = "", value = "separator" },
  { text = "Transpile program to javascript", value = "option13" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)                -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/lib/main.dart", true)  -- working_directory/lib/main.dart
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")                  -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/main")                  -- working_directory/bin/main
  local final_message = "--task finished--"


  --=========================== INTERPRETED =================================--
  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Dart interpreter",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this file → " .. current_file,
          cmd = "dart " .. current_file ..                                      -- run
                " && echo " .. current_file ..                                  -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Dart interpreter",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this file → " .. entry_point,
          cmd = "dart " .. entry_point ..                                       -- run
                " && echo " .. entry_point ..                                   -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
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
        entry_point = utils.os_path(variables.entry_point, true)
        local arguments = variables.arguments or "" -- optional
        task = { name = "- Run program → " .. entry_point,
          cmd = "dart " .. arguments .. " " .. entry_point ..                   -- run (interpreted)
                " && echo " .. entry_point ..                                   -- echo
                " && echo \"" .. final_message .. "\"",
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
            cmd = executable ..                                                 -- run
                  " && echo " .. executable ..                                  -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
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

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.dart")
      local arguments = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point, true)
        task = { name = "- Run program → " .. entry_point,
          cmd = "dart " .. arguments .. " " .. entry_point ..                   -- run (interpreted)
                " && echo " .. entry_point ..                                   -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Dart interpreter", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
    end












  --========================== MACHINE CODE =================================--
  elseif selected_option == "option4" then
    local arguments = "" -- optional
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build & run program → " .. entry_point,
          cmd = "rm -f \"" .. output .. "\" || true" ..                            -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                           -- mkdir
              " && dart compile exe " .. entry_point .. " -o \"" .. output .. "\" " .. arguments .. -- compile
              " && \"" .. output .. "\"" ..                                        -- run
              " && echo \"" .. entry_point .. "\"" ..                              -- echo
              " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option5" then
    local arguments = "" -- optional
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build program → " .. entry_point,
          cmd = "rm -f \"" .. output .. "\" || true" ..                            -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                           -- mkdir
              " && dart compile exe " .. entry_point .. " -o \"" .. output .. "\" " .. arguments .. -- compile
              " && echo \"" .. entry_point .. "\"" ..                              -- echo
              " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option6" then
    local arguments = "" -- optional
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run program → \"" .. output .. "\"",
          cmd = "\"" .. output .. "\"" ..                                          -- run
                " && echo \"" .. entry_point .. "\"" ..                            -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
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
        entry_point = utils.os_path(variables.entry_point, true)
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        local arguments = variables.arguments or "" -- optional
        task = { name = "- Run program → " .. entry_point,
          cmd = "rm -f \"" .. output ..  "\" || true" ..                             -- clean
                " && mkdir -p " .. output_dir ..                                     -- mkdir
                " && dart compile exe " .. entry_point .. " -o \"" .. output .. "\" " .. arguments .. -- compile
                " && echo " .. entry_point ..                                        -- echo
                " && echo \"" .. final_message .. "\"",
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
            cmd = executable ..                                              -- run
                  " && echo " .. executable ..                               -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
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

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.dart")
      local arguments = ""
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "../bin")                   -- entry_point/../bin
        output = utils.os_path(output_dir .. "/main")                                                     -- entry_point/bin/main
        task = { name = "- Build program → \"" .. entry_point .. "\"",
          cmd ="rm -f \"" .. output ..  "\" || true" ..                                                   -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                -- mkdir
                " && dart compile exe \"" .. entry_point .. "\" -o \"" .. output .. "\" " .. arguments .. -- compile
                " && echo \"" .. entry_point .. "\"" ..                                                   -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Dart compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
    end








  --============================= FLUTTER ===================================--
  elseif selected_option == "option8" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Flutter run",
          cmd = "flutter run " ..                                                         -- run
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option9" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Flutter build (linux)",
          cmd = "flutter build linux" ..                                                  -- compile for linux
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option10" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Flutter build (android)",
          cmd = "flutter build apk" ..                                                  -- compile for android
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option11" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Flutter build (ios)",
          cmd = "flutter build ios" ..                                                  -- compile for ios
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option12" then
    local task = overseer.new_task({
      name = "- Flutter compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Flutter build (web)",
          cmd = "flutter build web" ..                                                  -- compile for web
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()












  --= ================== TRANSPILE (TO JAVASCRIPT) ==========================--
  elseif selected_option == "option13" then
    local task = overseer.new_task({
      name = "- Dart compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Transpile to javascript → " .. entry_point,
          cmd = "dart compile js -o \"" .. output_dir .. "/js/\" "  .. entry_point ..   -- transpile to js
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  end
end

return M
