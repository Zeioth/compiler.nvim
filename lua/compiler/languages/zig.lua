--- Zig language actions
--- Note: You must initialize your project with:
--  'zig init-exe' or 'zig init-lib'
--- to use the compiler options defined here.

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Zig build and run program", value = "option1" },
  { text = "Zig build program", value = "option2" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local arguments = ""
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Zig compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build & run program → \"./build.zig\"",
          cmd = "zig build run " .. arguments ..                             -- compile and run
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Zig compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build program → \"./build.zig\"",
          cmd = "zig build " .. arguments ..                                 -- compile
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  end
end

return M
