--- Ruby language actions
-- Unlike most languages, ruby can be:
--   * interpreted
--   * compiled to machine code
--   * compiled to bytecode

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1  - Run this file (interpreted)", value = "option1" },
  { text = "2  - Run program (interpreted)", value = "option2" },
  { text = "3  - Run solution (interpreted)", value = "option3" },
  { text = "", value = "separator" },
  { text = "4  - Build and run program (machine code)", value = "option4" },
  { text = "5  - Build program (machine code)", value = "option5" },
  { text = "6  - Run program (machine code)", value = "option6" },
  { text = "7  - Build solution (machine code)", value = "option7" },
  { text = "", value = "separator" },
  { text = "8  - Build and run program (bytecode)", value = "option8" },
  { text = "9  - Build program (bytecode)", value = "option9" },
  { text = "10 - Run program (bytecode)", value = "option10" },
  { text = "11 - Run solution (bytecode)", value = "option11" },
  { text = "", value = "separator" },
  { text = "12 - Run Makefile", value = "option12" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = vim.fn.expand('%:p')            -- current file
  local entry_point = vim.fn.getcwd() .. "/main.rb"    -- working_directory/main.rb
  local output_dir = vim.fn.getcwd() .. "/bin/"        -- working_directory/bin/
  local output = vim.fn.getcwd() .. "/bin/program"     -- working_directory/bin/program
  local final_message = "--task finished--"
  -- For ruby, parameters are not globally defined,
  -- as we have 3 different ways to run the code.


  --=========================== INTERPRETED =================================--
  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Ruby interpreteer",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run this file → " .. current_file,
          cmd =  "time ruby " .. current_file ..                             -- run (interpreted)
                 " && echo '" .. final_message .. "'"                        -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Ruby interpreteer",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = "time ruby " .. output ..                                  -- run (interpreted)
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(vim.fn.getcwd() .. "/.solution")

      for entry, variables in pairs(config) do
        entry_point = variables.entry_point
        parameters = variables.parameters or parameters -- optional
        task = { "shell", name = "- Run program → " .. entry_point,
          cmd = "time ruby " .. entry_point .. " " .. parameters  ..         -- run (interpreted)
                " && echo '" .. final_message .. "'"                         -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({
        name = "- Ruby interpreteer", strategy = { "orchestrator",
          tasks = {
            tasks, -- Run all the programs in the solution in parallel
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.rb")
      parameters = variables.parameters or parameters -- optional
      for _, ep in ipairs(entry_points) do
        task = { "shell", name = "- Build program → " .. ep,
          cmd = "time ruby " .. ep .. " " .. parameters  ..                  -- run (interpreted)
                " && echo '" .. final_message .. "'"                         -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created secuentially
        name = "- Ruby interpreteer", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end












  --========================== MACHINE CODE =================================--
  elseif selected_option == "option4" then
    local parameters = variables.parameters or "-Wall" -- optional
    local task = overseer.new_task({
      name = "- Ruby machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                 -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && rubyc " .. entry_point .. " --output=" .. output .. " --make-args='" .. parameters .."'" .. -- compile to machine code
                " && time " .. output ..                                              -- run
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option5" then
    local parameters = variables.parameters or "-Wall" -- optional
    local task = overseer.new_task({
      name = "- Ruby machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                 -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && rubyc " .. entry_point .. " --output=" .. output .. " --make-args='" .. parameters .."'" .. -- compile to machine code
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option6" then
    local task = overseer.new_task({
      name = "- Ruby machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = "time " .. output ..                                       -- run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option7" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(vim.fn.getcwd() .. "/.solution")
      local executable

      for entry, variables in pairs(config) do
        executable = variables.executable
        if executable then goto continue end
        entry_point = variables.entry_point
        output = variables.output
        output_dir = output:match("^(.-[/\\])[^/\\]*$")
        local parameters = variables.parameters or "--warn-early" -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                 -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && rubyc " .. entry_point .. " --output=" .. output .. " --make-args='" .. parameters .."'" .. -- compile to machine code
                " && echo '" .. final_message .. "'"                                  -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      if executable then
        task = { "shell", name = "- Ruby machine code compiler",
          cmd = "time " .. executable ..                                     -- run
                " && echo '" .. final_message .. "'"                         -- echo
        }
      else
        task = {}
      end

      task = overseer.new_task({
        name = "- Build program → " .. entry_point, strategy = { "orchestrator",
          tasks = {
            tasks, -- Build all the programs in the solution in parallel
            task   -- Then run the solution executable
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")

      for _, ep in ipairs(entry_points) do
        output_dir = ep:match("^(.-[/\\])[^/\\]*$") .. "/bin"                -- entry_point/bin
        output = output_dir .. "/program"                                    -- entry_point/bin/program
        local parameters = "--warn-early" --optional
        task = { "shell", name = "- Build program → " .. ep,
          cmd = "rm -f " .. output ..                                        -- clean
                " && mkdir -p " .. output_dir ..                             -- mkdir
                " && rubyc " .. ep .. " --output=" .. output .. " --make-args='" .. parameters .."'" .. -- compile to machine code
                " && echo '" .. final_message .. "'"                         -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created secuentially
        name = "- Ruby machine code compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end












  --============================ BYTECODE ===================================--
  elseif selected_option == "option8" then
    local parameters = "--addopts '-W'" -- optional
    local task = overseer.new_task({
      name = "- Ruby bytecode compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                 -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && ruby --dump=insns " .. entry_point .. " > " .. output  .. parameters .. -- compile to bytecode
                " && time " .. output ..                                              -- run
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option9" then
    local parameters = "--addopts '-W'" -- optional
    local task = overseer.new_task({
      name = "- Ruby machine code compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                 -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && ruby --dump=insns " .. entry_point .. " > " .. output  .. parameters .. -- compile to bytecode
                " && echo '" .. final_message .. "'"                                  -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option10" then
    local task = overseer.new_task({
      name = "- Ruby bytecode compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = "time " .. output ..                                       -- run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option11" then
    local entry_points
    local tasks = {}
    local task

    -- if .solution file exists in working dir
    if utils.fileExists(".solution") then
      local config = utils.parseConfigFile(vim.fn.getcwd() .. "/.solution")
      local executable

      for entry, variables in pairs(config) do
        executable = variables.executable
        if executable then goto continue end
        entry_point = variables.entry_point
        output = variables.output
        output_dir = output:match("^(.-[/\\])[^/\\]*$")
        parameters = variables.parameters or "--addopts '-W'" -- optional
        task = { "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -f " .. output ..                                                 -- clean
                " && mkdir -p " .. output_dir ..                                      -- mkdir
                " && ruby --dump=insns " .. entry_point .. " > " .. output  .. parameters .. -- compile to bytecode
                " && echo '" .. final_message .. "'"                                  -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      if executable then
        task = { "shell", name = "- Ruby bytecode compiler",
          cmd = "time " .. executable ..                                     -- run
                " && echo '" .. final_message .. "'"                         -- echo
        }
      else
        task = {}
      end

      task = overseer.new_task({
        name = "- Build program → " .. entry_point, strategy = { "orchestrator",
          tasks = {
            tasks, -- Build all the programs in the solution in parallel
            task   -- Then run the solution executable
          }}})
      task:start()
      vim.cmd("OverseerOpen")

    else -- If no .solution file
      -- Create a list of all entry point files in the working directory
      entry_points = utils.find_files(vim.fn.getcwd(), "main.py")

      for _, ep in ipairs(entry_points) do
        output_dir = ep:match("^(.-[/\\])[^/\\]*$") .. "/bin"                -- entry_point/bin
        output = output_dir .. "/program"                                    -- entry_point/bin/program
        parameters = "--addopts '-W'" -- optional
        task = { "shell", name = "- Build program → " .. ep,
          cmd = "rm -f " .. output ..                                        -- clean
                " && mkdir -p " .. output_dir ..                             -- mkdir
                " && ruby --dump=insns " .. ep .. " > " .. output  .. parameters .. -- compile to bytecode
                " && echo '" .. final_message .. "'"                         -- echo
        }
        table.insert(tasks, task) -- store all the tasks we've created
      end

      task = overseer.new_task({ -- run all tasks we've created secuentially
        name = "- Ruby bytecode compiler", strategy = { "orchestrator", tasks = tasks }
      })
      task:start()
      vim.cmd("OverseerOpen")
    end











  --=============================== MAKE ====================================--
  elseif selected_option == "option12" then
    require("compiler.languages.make").run_makefile()                        -- run
  end

end

return M
