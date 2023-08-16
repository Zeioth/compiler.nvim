--- asm actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Build and run program", value = "option1" },
  { text = "2 - Build program",         value = "option2" },
  { text = "3 - Run program",           value = "option3" },
  { text = "4 - Build solution",        value = "option4" },
  { text = "5 - Run Makefile",          value = "option5" }
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
      local task = { "shell", name = "- Build program → " .. file,
        cmd = "mkdir -p " .. output_dir ..
              " && nasm -f elf64 " .. file .. " -o " .. output_o .. " ".. arguments ..  -- compile
              " && echo " .. file ..                                                    -- echo
              " && echo '" .. final_message .. "'"
      }
      files[_] = output_dir .. filename .. ".o" -- prepare for linker
      table.insert(tasks_compile, task)
    end
    -- Link .o files
    files = table.concat(files ," ") -- table to string
    local task_link = { "shell", name = "- Link program → " .. entry_point,
      cmd = "ld " .. files .. " -o " .. output ..                                  -- link
            " && rm -f " .. files ..                                               -- clean
            " && " .. output ..                                                    -- run
            " && echo " .. output ..                                               -- echo
            " && echo '" .. final_message .. "'"
    }
    -- Run program
    local task_run = { "shell", name = "- Run program → " .. output,
      cmd = output ..                                                              -- run
            " && echo " .. output ..                                               -- echo
            " && echo '" .. final_message .. "'"
    }
    -- Runs tasks in order
    task = overseer.new_task({
      name = "- Assembly compiler", strategy = { "orchestrator",
        tasks = {
          tasks_compile, -- Build .asm files in parallel
          task_link,     -- Link .o files
          task_run       -- Run program
        }}})
    task:start()
    vim.cmd("OverseerOpen")

  elseif selected_option == "option2" then
    -- Build .asm files in parallel
    local tasks_compile = {}
    for _, file in pairs(files) do
      local filename = vim.fn.fnamemodify(file, ":t")
      local output_o = output_dir .. filename .. ".o"
      local task = { "shell", name = "- Build program → " .. file,
        cmd = "mkdir -p " .. output_dir ..
              " && nasm -f elf64 " .. file .. " -o " .. output_o .. " " .. arguments  ..   -- compile
              " && echo " .. file ..                                                       -- echo
              " && echo '" .. final_message .. "'"
      }
      files[_] = output_dir .. filename .. ".o" -- prepare for linker
      table.insert(tasks_compile, task)
    end
    -- Link .o files
    files = table.concat(files ," ") -- table to string
    local task_link = { "shell", name = "- Link program → " .. entry_point,
      cmd = "ld " .. files .. " -o " .. output ..                                  -- link
           " && rm -f " .. files ..                                                -- clean
           " && echo " .. output ..                                                -- echo
           " && echo '" .. final_message .. "'"
    }
    -- Runs tasks in order
    task = overseer.new_task({
      name = "- Assembly compiler", strategy = { "orchestrator",
        tasks = {
          tasks_compile, -- Build .asm files in parallel
          task_link,     -- Link .o files
        }}})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Assembly compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
          cmd = output ..                                                          -- run
                " && echo && echo " .. output ..                                   -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.file_exists(".solution.toml") then
      local config = utils.parse_config_file(
        utils.os_path(vim.fn.getcwd() .. "/.solution.toml"))
      local executable

      for entry, variables in pairs(config) do
        if variables.executable then
          executable = utils.os_path(variables.executable)
          goto continue
        end
        entry_point = utils.os_path(variables.entry_point)
        entry_point_dir = vim.fn.fnamemodify(entry_point, ":h")
        files = utils.find_files(entry_point_dir, "*.asm")
        output = utils.os_path(variables.output)                              -- entry_point/bin/program
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))        -- entry_point/bin
        arguments = variables.arguments or arguments -- optional

        -- Build .asm files in parallel
        local tasks_compile = {}
        for _, file in pairs(files) do
          local filename = vim.fn.fnamemodify(file, ":t")
          local output_o = output_dir .. filename .. ".o"
          local task = { "shell", name = "- Build program → " .. file,
            cmd = "mkdir -p " .. output_dir ..
                  " && nasm -f elf64 " .. file .. " -o " .. output_o .. " " .. arguments ..    -- compile
                  " && echo " .. file ..                                               -- echo
                  " && echo '" .. final_message .. "'"
          }
          files[_] = output_dir .. filename .. ".o" -- prepare for linker
          table.insert(tasks_compile, task)
        end
        -- Link .o files
        files = table.concat(files ," ") -- table to string
        local task_link = { "shell", name = "- Link program → " .. entry_point,
          cmd = "ld " .. files .. " -o " .. output ..                            -- link
               " && rm -f " .. files ..                                          -- clean
               " && echo " .. output ..                                          -- echo
               " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, tasks_compile) -- store all the tasks we've created
        table.insert(tasks, task_link)
        ::continue::
      end

      if executable then
        task = { "shell", name = "- Run program → " .. executable,
          cmd = executable ..                                                -- run
                " && echo && echo " .. executable ..                         -- echo
                " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, task)
      else
        task = {}
      end

      task = overseer.new_task({
        name = "- Assembly compiler", strategy = { "orchestrator",
          tasks = tasks
        }})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.asm")

      -- For every entry point
      for _, entry_point in ipairs(entry_points) do
        entry_point = utils.os_path(entry_point)
        entry_point_dir = vim.fn.fnamemodify(entry_point, ":h")
        files = utils.find_files(entry_point_dir, "*.asm")
        output_dir = utils.os_path(entry_point:match("^(.-[/\\])[^/\\]*$") .. "bin")        -- entry_point/bin
        output = utils.os_path(output_dir .. "/program")                                    -- entry_point/bin/program

        -- Build .asm files in parallel
        local tasks_compile = {}
        for _, file in pairs(files) do
          local filename = vim.fn.fnamemodify(file, ":t")
          local output_o = output_dir .. filename .. ".o"
          local task = { "shell", name = "- Build program → " .. file,
            cmd = "mkdir -p " .. output_dir ..
                  " && nasm -f elf64 " .. file .. " -o " .. output_o .. " " .. arguments ..  -- compile
                  " && echo " .. file ..                                                     -- echo
                  " && echo '" .. final_message .. "'"
          }
          files[_] = output_dir .. filename .. ".o" -- prepare for linker
          table.insert(tasks_compile, task)
        end
        -- Link .o files
        files = table.concat(files ," ") -- table to string
        local task_link = { "shell", name = "- Link program → " .. entry_point,
          cmd = "ld " .. files .. " -o " .. output ..                            -- link
               " && rm -f " .. files ..                                          -- clean
               " && echo '" .. final_message .. "'"
        }
        table.insert(tasks, tasks_compile) -- store all the tasks we've created
        table.insert(tasks, task_link)
      end

      task = overseer.new_task({
        name = "- Assembly compiler", strategy = { "orchestrator",
          tasks = tasks
        }})
      task:start()
      vim.cmd("OverseerOpen")
    end
  elseif selected_option == "option5" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
