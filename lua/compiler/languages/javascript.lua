--- Javascript language actions

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Run program",   value = "option2" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)               -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/src/index.js", true)  -- working_directory/index.js
  local arguments = ""
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Javascript interpreter",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this file → " .. current_file,
          cmd = "node " .. arguments .. " " .. current_file ..               -- run program (interpreted)
                " && echo " .. current_file ..                               -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Javascript interpreter",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this program → " .. entry_point,
          cmd = "node " .. arguments .. " " .. entry_point ..                -- run program (interpreted)
                " && echo " .. entry_point ..                                -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  end

end

return M
