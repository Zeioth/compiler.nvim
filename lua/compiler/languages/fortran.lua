--- Fortran language actions

local M = {}

-- Frontend - options displayed on telescope
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "FPM build and run", value = "option2" },
  { text = "FPM build", value = "option3" },
  { text = "FPM run", value = "option4" },
}

-- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)                           -- current file
  local output_dir = utils.os_path(vim.fn.stdpath("cache") .. "/compiler/fortran/")        -- working_directory/bin/
  local output = output_dir .. "program"                                                   -- working_directory/bin/program
  local arguments = ""                                                                     -- arguments can be overriden in .solution
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this file → " .. current_file,
          cmd = "rm -f \"" .. output ..  "\" || true" ..                                   -- clean
                " && mkdir -p \"" .. output_dir .. "\"" ..                                 -- mkdir
                " && gfortran " .. current_file .. " -o \"" .. output .. "\" " .. arguments .. -- compile
                " && " .. output ..                                                        -- run
                " && echo " .. current_file ..                                             -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- fpm build & run → " .. "\"./fpm.toml\"",
          cmd = "fpm build " ..                                              -- compile
                " && fpm run" ..                                             -- run
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- fpm build → " .. "\"./fpm.toml\"",
          cmd = "fpm build " ..                                              -- compile
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option4" then
    local task = overseer.new_task({
      name = "- Fortran compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- fpm run → " .. "\"./fpm.toml\"",
          cmd = "fpm run " ..                                                -- compile
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
   end
end

return M

