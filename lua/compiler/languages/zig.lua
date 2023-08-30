--- Zig language actions
--- Note: You must initialize your project with:
--  'zig init-exe' or 'zig init-lib'
--- to use the compiler options defined here.

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Zig build and run program", value = "option1" },
  { text = "2 - Zig build program", value = "option2" },
  { text = "3 - Run Makefile", value = "option3" }
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
        tasks = {{ "shell", name = "- Build & run program → build.zig",
          cmd = "zig build run " .. arguments ..                             -- compile and run
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Zig compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → build.zig",
          cmd = "zig build " .. arguments ..                                 -- compile
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
