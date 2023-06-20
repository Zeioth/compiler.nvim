--- make language actions
-- Supporting this filetype  allow the user
-- to run the compiler while editing a Makefile.

local M = {}

-- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Run Makefile", value = "option1" }
}

-- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  if selected_option == "option5" then
    local makefile = vim.fn.getcwd() .. "/Makefile"
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run Makefile → " .. makefile,
            cmd = "time make -f " .. makefile ..                                -- run
                " ; echo '" .. final_message .. "'"                          -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")

  end
end

return M
