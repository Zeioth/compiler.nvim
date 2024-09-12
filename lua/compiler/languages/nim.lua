--- Nim language actions

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Build and run main program", value = "option1" },
  { text = "Build main program", value = "option2" },
  { text = "Run main program", value = "option3" },
  { text = "Build solution", value = "option4" },
  { text = "Run this file", value = "option5" },
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = vim.fn.expand("%:p")

  local entry_point = utils.os_path(vim.fn.getcwd() .. "/src/main.nim") -- working_directory/main.nim
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/bin/") -- working_directory/bin/
  local output = utils.os_path(vim.fn.getcwd() .. "/bin/program") -- working_directory/bin/program
  local current_file_output = output_dir
    .. vim.fn.fnamemodify(current_file, ":t:r")

  local arguments = "" -- arguments can be overriden in .solution
  local final_message = "--task finished--"

  if selected_option == "option1" then
    -- stylua: ignore start
    local task = overseer.new_task({
      name = "- Nim compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build & run program → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output .. "\" || true" ..                           -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                          -- mkdir
              " && nim c -r " .. arguments .. " -o=" .. output .. " " .. entry_point ..  -- compile
              -- " && \"" .. output .. "\"" ..                                       -- run
              " && echo \"" .. entry_point .. "\"" ..                             -- echo
              " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
    -- stylua: ignore end
  elseif selected_option == "option2" then
    -- stylua: ignore start
    local task = overseer.new_task({
      name = "- Nim compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build program → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output .. "\" || true" ..                           -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                          -- mkdir
              " && nim c " .. arguments .. " -o=" .. output .. " " .. entry_point ..  -- compile
              " && echo \"" .. entry_point .. "\"" ..                             -- echo
              " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
    -- stylua: ignore end
  elseif selected_option == "option3" then
    -- stylua: ignore start
    local task = overseer.new_task({
      name = "- Nim compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run program → \"" .. output .. "\"",
          cmd = "\"" .. output .. "\"" ..                                         -- run
              " && echo \"" .. output .. "\"" ..                                  -- echo
              " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
    -- stylua: ignore end
  elseif selected_option == "option4" then
    local entry_points
    local task = {}
    local tasks = {}
    local executables = {}

    local solution_file = utils.get_solution_file()
    if solution_file then
      local config = utils.parse_solution_file(solution_file)

      for entry, variables in pairs(config) do
        if entry == "executables" then goto continue end
        entry_point = utils.os_path(variables.entry_point)
        output = utils.os_path(variables.output)
        output_dir = utils.os_path(output:match("^(.-[/\\])[^/\\]*$"))
        arguments = variables.arguments or arguments -- optional
        -- stylua: ignore start
        task = { name = "- Build program → \"" .. entry_point .. "\"",
          cmd = "rm -f \"" .. output .. "\" || true" ..                           -- clean
              " && mkdir -p \"" .. output_dir .. "\"" ..                          -- mkdir
              " && nim c " .. arguments .. " -o=" .. output .. " " .. entry_point ..  -- compile
              " && echo \"" .. entry_point .. "\"" ..                             -- echo
              " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        }
        -- stylua: ignore end
        table.insert(tasks, task) -- store all the tasks we've created
        ::continue::
      end

      local solution_executables = config["executables"]
      if solution_executables then
        for entry, executable in pairs(solution_executables) do
          executable = utils.os_path(executable, true)
          -- stylua: ignore start
          task = { name = "- Run program → " .. executable,
            cmd = executable ..                                                   -- run
                  " && echo " .. executable ..                                    -- echo
                  " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          }
          -- stylua: ignore end
          table.insert(executables, task) -- store all the executables we've created
        end
      end

      task = overseer.new_task({
        name = "- Nim compiler",
        strategy = {
          "orchestrator",
          tasks = {
            tasks, -- Build all the programs in the solution in parallel
            executables, -- Then run the solution executable(s)
          },
        },
      })
      task:start()
    end
  elseif selected_option == "option5" then
      -- stylua: ignore start
      local task = overseer.new_task({
        name = "- Nim compiler",
        strategy = { "orchestrator",
          tasks = {{ name = "- Build & run program → \"" .. current_file .. "\"",
            cmd = "rm -f \"" .. current_file_output .. "\" || true" ..                           -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                          -- mkdir
                " && nim c -r " .. arguments .. " -o=" .. current_file_output .. " " .. current_file ..  -- compile
                " && echo \"" .. current_file .. "\"" ..                             -- echo
                " && echo \"" .. final_message .. "\"",
            components = { "default_extended" }
          },},},})
      task:start()
  end
end

return M
