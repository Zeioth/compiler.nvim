--- asm actions

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Build and run program", value = "option1" },
  { text = "Build program",         value = "option2" },
  { text = "Run program",           value = "option3" },
  { text = "Build solution",        value = "option4" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/main.asm")          -- working_directory/main.asm
  local entry_point_dir = vim.fn.fnamemodify(entry_point, ":h")              -- working_directory/
  local files = utils.find_files(entry_point_dir, "*.asm")                   -- *.asm files under entry_point_dir (recursively)
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/")               -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/program")            -- working_directory/bin/program
  local arguments = "-g"                                                     -- arguments can be overriden in .solution
  local final_message = "--task finished--"

  if selected_option == "option1" then
    -- Build .asm files in parallel
    local tasks_compile = {}
    for _, file in pairs(files) do
      local filename = vim.fn.fnamemodify(file, ":t")
      local output_o = output_dir .. filename .. ".o"
      file = utils.os_path(file, true)
      local task = { name = "- Build program → " .. file,
        cmd = "rm -f \"" .. output .. "\" || true" ..                                       -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                                    -- mkdir
              " && nasm -f elf64 " .. file .. " -o \"" .. output_o .. "\" ".. arguments ..  -- compile
              " && echo " .. file ..                                                        -- echo
              " && echo \"" .. final_message .. "\"",
        components = { "default_extended" }
      }
      files[_] = utils.os_path(output_dir .. filename .. ".o", true)         -- prepare for linker
      table.insert(tasks_compile, task)
    end
    -- Link .o files
    files = table.concat(files ," ") -- table to string
    local task_link = { name = "- Link program → \"" .. entry_point .."\"" ,
      cmd = "ld " .. files .. " -o \"" .. output .. "\"" ..                  -- link
            " && rm -f " .. files .. " || true" ..                           -- clean
            " && \"" .. output .. "\"" ..                                    -- run
            " && echo && echo \"" .. entry_point .. "\"" ..                  -- echo
            " && echo \"" .. final_message .. "\"",
      components = { "default_extended" }
    }
    -- Run program
    local task_run = { name = "- Run program → \"" .. output .. "\"",
      cmd = utils.os_path(output, true) ..                                   -- run
            " && echo && echo \"" .. output .. "\"" ..                       -- echo
            " && echo \"" .. final_message .. "\"",
      components = { "default_extended" }
    }
    -- Runs tasks in order
    local task = overseer.new_task({
      name = "- Assembly compiler", strategy = { "orchestrator",
        tasks = {
          tasks_compile, -- Build .asm files in parallel
          task_link,     -- Link .o files
          task_run       -- Run program
        }}})
    task:start()

  elseif selected_option == "option2" then
    -- Build .asm files in parallel
    local tasks_compile = {}
    for _, file in pairs(files) do
      local filename = vim.fn.fnamemodify(file, ":t")
      local output_o = output_dir .. filename .. ".o"
      file = utils.os_path(file, true)
      local task = { name = "- Build program → " .. file,
        cmd = "rm -f \"" .. output .. "\" || true" ..                                        -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                                     -- mkdir
              " && nasm -f elf64 " .. file .. " -o \"" .. output_o .. "\" " .. arguments  .. -- compile
              " && echo " .. file ..                                                         -- echo
              " && echo \"" .. final_message .. "\"",
        components = { "default_extended" }
      }
      files[_] = utils.os_path(output_dir .. filename .. ".o", true)         -- prepare for linker
      table.insert(tasks_compile, task)
    end
    -- Link .o files
    files = table.concat(files ," ") -- table to string
    local task_link = { name = "- Link program → \"" .. entry_point .. "\"",
      cmd = "ld " .. files .. " -o \"" .. output .. "\"" ..                  -- link
           " && rm -f " .. files .. " || true" ..                            -- clean
           " && echo \"" .. entry_point .. "\"" ..                           -- echo
           " && echo \"" .. final_message .. "\"",
      components = { "default_extended" }
    }
    -- Runs tasks in order
    local task = overseer.new_task({
      name = "- Assembly compiler", strategy = { "orchestrator",
        tasks = {
          tasks_compile, -- Build .asm files in parallel
          task_link,     -- Link .o files
        }}})
    task:start()
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Assembly compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run program → \"" .. output .. "\"",
          cmd = "\"" .. output .. "\"" ..                                    -- run
                " && echo && echo \"" .. output .. "\"" ..                   -- echo
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
        entry_point_dir = vim.fn.fnamemodify(entry_point, ":h")
        files = utils.find_files(entry_point_dir, "*.asm")
        output = utils.os_path(variables.output)                             -- entry_point/bin/program
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))       -- entry_point/bin
        arguments = variables.arguments or arguments -- optional

        -- Build .asm files in parallel
        local tasks_compile = {}
        for _, file in pairs(files) do
          local filename = vim.fn.fnamemodify(file, ":t")
          local output_o = output_dir .. filename .. ".o"
          file = utils.os_path(file, true)
          local task = { name = "- Build program → " .. file,
            cmd = "rm -f \"" .. output .. "\" || true" ..                                       -- clean
                  " && mkdir -p \"" .. output_dir .. "\"" ..                                    -- mkdir
                  " && nasm -f elf64 " .. file .. " -o \"" .. output_o .. "\" " .. arguments .. -- compile
                  " && echo " .. file ..                                                        -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          }
          files[_] = utils.os_path(output_dir .. filename .. ".o", true)     -- prepare for linker
          table.insert(tasks_compile, task)
        end
        -- Link .o files
        files = table.concat(files ," ") -- table to string
        local task_link = { name = "- Link program → " .. entry_point,
          cmd = "ld " .. files .. " -o \"" .. output .. "\"" ..              -- link
               " && rm -f " .. files ..  " || true" ..                       -- clean
               " && echo \"" .. entry_point .. "\""  ..                      -- echo
               " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        table.insert(tasks, tasks_compile) -- store all the tasks we've created
        table.insert(tasks, task_link)
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          utils.os_path(executable, true)
          task = { name = "- Run program → " .. executable,
            cmd = executable ..                                              -- run
                  " && echo && echo " .. executable ..                       -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          }
          table.insert(executables, task)  -- store all the executables we've created
          table.insert(tasks, executables)
        end
      end

      task = overseer.new_task({
        name = "- Assembly compiler", strategy = { "orchestrator",
          tasks = tasks -- Build all the programs in the solution in parallel
                        -- Link all the programs in the solution in parallel
--                      -- Then run the solution executable(s)
        }})
      task:start()

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.asm")

      -- For every entry point
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        entry_point_dir = vim.fn.fnamemodify(entry_point, ":h")
        files = utils.find_files(entry_point_dir, "*.asm")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")  -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                              -- entry_point/bin/program

        -- Build .asm files in parallel
        local tasks_compile = {}
        for _, file in pairs(files) do
          local filename = vim.fn.fnamemodify(file, ":t")
          local output_o = output_dir .. filename .. ".o"
          file = utils.os_path(file, true)
          local task = { name = "- Build program → " .. file,
            cmd = "rm -f \"" .. output .. "\" || true" ..                                       -- clean
                  " && mkdir -p \"" .. output_dir .. "\"" ..                                    -- mkdir
                  " && nasm -f elf64 " .. file .. " -o \"" .. output_o .. "\" " .. arguments .. -- compile
                  " && echo " .. file ..                                                        -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          }
          files[_] = utils.os_path(output_dir .. filename .. ".o", true)     -- prepare for linker
          table.insert(tasks_compile, task)
        end
        -- Link .o files
        files = table.concat(files ," ") -- table to string
        local task_link = { name = "- Link program → \"" .. entry_point .. "\"",
          cmd = "ld " .. files .. " -o \"" .. output .. "\"" ..              -- link
               " && rm -f " .. files ..  " || true" ..                       -- clean
               " && echo \"" .. entry_point .. "\"" ..                       -- echo
               " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        table.insert(tasks, tasks_compile) -- store all the tasks we've created
        table.insert(tasks, task_link)
      end

      task = overseer.new_task({
        name = "- Assembly compiler", strategy = { "orchestrator",
          tasks = tasks
        }})
      task:start()
    end
  end
end

return M
