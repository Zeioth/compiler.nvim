--- Java language actions

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Build and run program (class)", value = "option1" },
  { text = "Build program (class)", value = "option2" },
  { text = "Run program (class)", value = "option3" },
  { text = "Build solution (class)", value = "option4" },
  { text = "", value = "separator" },
  { text = "Build and run program (jar)", value = "option5" },
  { text = "Build program (jar)", value = "option6" },
  { text = "Run program (jar)", value = "option7" },
  { text = "Build solution (jar)", value = "option8" },
  { text = "", value = "separator" },
  { text = "Run REPL", value = "option9" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/Main.java")         -- working_directory/Main.java
  local files = utils.find_files_to_compile(entry_point, "*.java")           -- *.java files under entry_point_dir (recursively)
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")               -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/Main")               -- working_directory/bin/Main.class
  local output_filename = "Main"                                             -- working_directory/bin/Main
  local arguments = "-Xlint:all"                                             -- arguments can be overriden in .solution
  local final_message = "--task finished--"

  --========================== Build as class ===============================--
  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Java compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build & run program (class) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output_dir .. "*.class\"" .. " || true" ..                   -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                 -- mkdir
                " && javac -d \"" .. output_dir .. "\" " .. arguments .. " " .. files ..   -- compile bytecode (.class)
                " && java -cp \"" .. output_dir .. "\" " .. output_filename ..             -- run
                " && echo \"" .. entry_point .. "\"" ..                                    -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Java compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build program (class) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output_dir .. "/*.class\"" .. " || true" ..                  -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                 -- mkdir
                " && javac -d \"" .. output_dir .. "\" " .. arguments .. " "  .. files ..  -- compile bytecode (.class)
                " && echo \"" .. entry_point .. "\"" ..                                    -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Java compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run program (class) → \"" .. output .. ".class\"",
          cmd = "java -cp \"" .. output_dir .. "\" " .. output_filename ..                 -- run
                " && echo \"" .. output .. ".class\"" ..                                   -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
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
        files = utils.find_files_to_compile(entry_point, "*.java")
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optiona
        task = { name = "- Build program (class) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output_dir .. "/*.class\"" .. " || true" ..                  -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                 -- mkdir
                " && javac -d \"" .. output_dir .. "\" " .. arguments .. " "  .. files ..  -- compile bytecode
                " && echo \"" .. entry_point .. "\""  ..                                   -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          output_dir = utils.os_path(executable:match("^(.-[/\\])[^/\\]*$"))
          output_filename = vim.fn.fnamemodify(executable, ':t:r')
          task = { name = "- Run program (class) → \"" .. executable .. "\"",
            cmd = "java -cp \"" .. output_dir .. "\" " .. output_filename ..               -- run
                  " && echo \"" .. output_dir .. output_filename .. ".class\"" ..          -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          }
          table.insert(executables, task) -- store all the executables we've created
        end
      end

      task = overseer.new_task({
        name = "- Java compiler", strategy = { "orchestrator",
          tasks = {
            tasks,        -- Build all the programs in the solution in parallel
            executables   -- Then run the solution executable(s)
          }}})
      task:start()

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "Main.java")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        files = utils.find_files_to_compile(entry_point, "*.java")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")       -- entry_point/bin
        task = { name = "- Build program (class) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output_dir .. "/*.class\"" .. " || true" ..                  -- clean
                " && mkdir -p \"" .. output_dir .."\"" ..                                  -- mkdir
                " && javac -d \"" .. output_dir .. "\" " .. arguments .. " "  .. files ..  -- compile bytecode
                " && echo \"" .. entry_point .. "\"" ..                                    -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Java compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
    end








  --=========================== Build as jar ================================--
  elseif selected_option == "option5" then
    local task = overseer.new_task({
      name = "- Java compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build & run program (jar) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output .. ".jar\"" .. " || true" ..                                           -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                  -- mkdir
                " && jar cfe \"" .. output .. ".jar\" " .. output_filename .. " -C \"" .. output_dir .. "\" . " ..  -- compile bytecode (.jar)
                " && java -jar \"" .. output .. ".jar\"" ..                                                 -- run
                " && echo \"" .. entry_point .. "\"" ..                                                     -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option6" then
    local task = overseer.new_task({
      name = "- Java compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build program (jar) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output .. ".jar\"" .. " || true" ..                                           -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                  -- mkdir
                " && jar cfe \"" .. output .. ".jar\" " .. output_filename .. " -C \"" .. output_dir .. "\" . " ..  -- compile bytecode (.jar)
                " && echo \"" .. entry_point .. "\"" ..                                                     -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option7" then
    local task = overseer.new_task({
      name = "- Java compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run program (jar) → \"" .. output .. ".jar\"",
          cmd = "java -jar \"" .. output .. ".jar\"" ..                                                     -- run
                " && echo \"" .. output .. ".jar\""  ..                                                     -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option8" then
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
        files = utils.find_files_to_compile(entry_point, "*.java")
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        output_filename = vim.fn.fnamemodify(output, ':t:r')
        arguments = variables.arguments or arguments -- optional
        task = { name = "- Build program (jar) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output .. "\" || true" ..                                                     -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                  -- mkdir
                " && jar cfe \"" .. output .. "\" " .. output_filename .. " -C \"" .. output_dir .. "\" . " ..  -- compile bytecode (jar)
                " && echo \"" .. entry_point .. "\"" ..                                                     -- echo
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
          task = { name = "- Run program (jar) → \"" .. executable .. "\"",
            cmd = "java -jar " .. executable ..                                                             -- run
                  " && echo " .. executable ..                                                              -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          }
          table.insert(executables, task) -- store all the executables we've created
        end
      end

      task = overseer.new_task({
        name = "- Java compiler", strategy = { "orchestrator",
          tasks = {
            tasks,        -- Build all the programs in the solution in parallel
            executables   -- Then run the solution executable(s)
          }}})
      task:start()

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "Main.java")

      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")                            -- entry_point/bin
        output = utils.os_path(output_dir .. "/Main")                                                           -- entry_point/bin/Main.jar
        task = { name = "- Build program (jar) → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output .. ".jar\" " .. " || true" ..                                              -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                                      -- mkdir
                " && jar cfe \"" .. output .. ".jar\" " .. output_filename .. " -C \"" .. output_dir .. "\" . " ..  -- compile bytecode (jar)
                " && echo \"" .. entry_point .. "\"" ..                                                         -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created in parallel
        name = "- Java compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
    end








  --========================== MISC ===============================--
  elseif selected_option == "option9" then
    local task = overseer.new_task({
      name = "- Java compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Start REPL",
          cmd = "echo 'To exit the REPL enter /exit'" ..                     -- echo
                " && jshell " ..                                             -- run (repl)
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  end
end

return M
