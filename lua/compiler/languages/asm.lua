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
  local actual_filename = vim.fn.expand('%:t')                               -- example.asm
  local actual_filename_without_extension = vim.fn.expand('%:t:r')           -- example
  local overseer = require("overseer")
  local entry_point = vim.fn.getcwd() .. "/" .. actual_filename              -- working_directory/example.cpp
  local output_dir = vim.fn.getcwd() .. "/"                                  -- working_directory
  local output = vim.fn.getcwd() .. "/" .. actual_filename_without_extension -- working_directory/filename
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- nasm ",
      strategy = {
        "orchestrator",
        tasks = { {
          "shell",
          name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. actual_filename_without_extension ..                 -- clean
              " && nasm -f elf64 " .. entry_point .. " -o " .. output .. ".o" .. -- compile
              " && ld " .. output .. ".o " .. "-o " .. output ..                 -- link
              " && time " ..
              "./" .. actual_filename_without_extension ..                       -- run
              " && echo '" .. final_message .. "'"                               -- echo
        }, },
      },
    })
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- nasm ",
      strategy = {
        "orchestrator",
        tasks = { {
          "shell",
          name = "- Build & run program → " .. entry_point,
          cmd = "rm -f " .. actual_filename_without_extension ..                 -- clean
              " && nasm -f elf64 " .. entry_point .. " -o " .. output .. ".o" .. -- compile
              " && ld " .. output .. ".o " .. "-o " .. output ..                 -- link
              " && echo '" .. final_message .. "'"                               -- echo
        }, },
      },
    })
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- nasm ",
      strategy = {
        "orchestrator",
        tasks = { {
          "shell",
          name = "- Build & run program → " .. entry_point,
          cmd = "time " ..
              "./" .. actual_filename_without_extension .. -- run
              " && echo '" .. final_message .. "'"         -- echo
        }, },
      },
    })
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    require("compiler.languages.make").run_makefile() -- run
  end
end

return M
