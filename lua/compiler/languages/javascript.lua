--- Javascript language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Run this file", value = "option1" },
  { text = "2 - Run program",   value = "option2" },
  { text = "3 - npm install",  value = "option3" },
  { text = "4 - npm start",  value = "option4" },
  { text = "5 - Run Makefile",  value = "option5" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = vim.fn.expand('%:p')                                   -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/src/index.js")       -- working_directory/index.js
  local arguments = ""
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Javascript interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run this file → " .. current_file,
          cmd = "node " .. arguments .. " " .. current_file ..               -- run program (interpreted)
                " && echo " .. current_file ..                               -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Javascript interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run this program → " .. entry_point,
          cmd = "node " .. arguments .. " " .. entry_point ..                -- run program (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Typescript interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- npm install → package.json",
          cmd = "npm install" ..                                             -- install dependencies
                " && echo npm install" ..                                    -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    local task = overseer.new_task({
      name = "- Typescript interpreter",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- npm run → package.json",
          cmd = "npm start" ..                                               -- run
                " && echo npm start" ..                                      -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
    vim.cmd("OverseerOpen")
  elseif selected_option == "option5" then
    require("compiler.languages.make").run_makefile()                        -- run
  end

end

return M
