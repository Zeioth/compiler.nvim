--- Make language actions
-- Supporting this filetype allow the user
-- to use the compiler while editing a Makefile.

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Run Makefile", value = "option1" }
}

--- Helper
-- Runs ./Makefile in the current working directory.
-- This prevents code repetition as this method is meant to be called by
-- all other languages to act as glue for border cases.
function M.run_makefile()
  local overseer = require("overseer")
  local final_message = "--task finished--"
  local makefile = vim.fn.getcwd() .. "/Makefile"
  local task = overseer.new_task({
    name = "- C compiler",
    strategy = { "orchestrator",
      tasks = {{ "shell", name = "- Run Makefile → " .. makefile,
          cmd = "time make -f " .. makefile ..                               -- run
              " ; echo '" .. final_message .. "'"                            -- echo
      },},},})
  task:start()
  vim.cmd("OverseerOpen")
end

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  if selected_option == "option1" then
    M.run_makefile()
  end
end

return M
