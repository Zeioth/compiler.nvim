--- Make language actions
-- Supporting this filetype allow the user
-- to use the compiler while editing a Makefile.

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Run Makefile", value = "option1" }
}

--- Helper
-- Runs ./Makefile in the current working directory.
function M.run_makefile()
  -- If no makefile, show a warning notification and return.
  local stat = vim.loop.fs_stat("./Makefile")
  if not stat then
    vim.notify("You must have a Makefile in your working directory", vim.log.levels.WARN, {
      title = "Compiler.nvim"
    })
    return
  end

  -- Run makefile
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local makefile = utils.os_path(vim.fn.getcwd() .. "/Makefile", true)
  local final_message = "--task finished--"
  local task = overseer.new_task({
    name = "- Make interpreter",
    strategy = { "orchestrator",
      tasks = {{ name = "- Run Makefile → " .. makefile,
          cmd = "make -f " .. makefile ..                                    -- run
                " && echo " .. makefile ..                                   -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
      },},},})
  task:start()
end

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  if selected_option == "option1" then
    M.run_makefile()
  end
end

return M
