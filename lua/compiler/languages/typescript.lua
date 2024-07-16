--- Typescript language actions

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
  local current_file = vim.fn.expand('%:p')                                  -- current file
  local entry_point = utils.os_path(vim.fn.getcwd() .. "/src/index.ts")      -- working_directory/index.ts
  local output_dir = utils.os_path(vim.fn.getcwd() .. "/dist/")              -- working_directory/dist/
  local arguments = "--outDir " .. utils.os_path(output_dir, true)
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local current_file_js = output_dir .. vim.fn.fnamemodify(current_file, ":t:r") .. ".js"
    local task = overseer.new_task({
      name = "- Typescript interpreter",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this file → \"" .. current_file .. "\"",
          cmd = "npx tsc " .. arguments ..                                   -- transpile to js
                " && node \"" .. current_file_js .. "\"" ..                  -- run program (interpreted)
                " && echo \"" .. current_file .. "\"" ..                     -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local entry_point_js =  output_dir .. vim.fn.fnamemodify(entry_point, ":t:r") .. ".js"
    local task = overseer.new_task({
      name = "- Typescript interpreter",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this program → \"" .. entry_point .. "\"",
          cmd = "npx tsc " .. arguments ..                                   -- transpile to js
                " && node \"" .. entry_point_js .. "\"" ..                   -- run program (interpreted)
                " && echo \"" .. entry_point .. "\"" ..                      -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  end

end

return M
