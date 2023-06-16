--- c language actions

local M = {}

-- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Build and run", value = "option1" },
  { text = "2 - Build", value = "option2" },
  { text = "3 - Run", value = "option3" },
  { text = "4 - Build solution", value = "option4" }
}

-- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local entry_point = vim.fn.getcwd() .. "/main.c" -- working_directory/main.c
  local output = vim.fn.getcwd() .. "/bin/program" -- working_directory/bin/program
  local toggleterm_split = "hsplit"                -- TODO: Move this to a config file

  if selected_option == "option1" then  -- If option 1
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "",
            cmd = "rm -f " .. output ..                         -- clean
              " && gcc " .. entry_point .. " -o " .. output ..  -- compile
              " -Wall && time " .. output,                      -- run
        },},},})
    task:start()
    overseer.run_action(task, "open " .. toggleterm_split)
  elseif selected_option == "option2" then -- If option 2
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build → " .. entry_point,
            cmd = "rm -f " .. output ..                         -- clean
              " && gcc " .. entry_point .. " -o " .. output     -- compile
        },},},})
    task:start()
    overseer.run_action(task, "open " .. toggleterm_split)
  elseif selected_option == "option3" then -- If option 3
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run → " .. entry_point,
            cmd = "time " .. output,                           -- run
        },},},})
    task:start()
    overseer.run_action(task, "open " .. toggleterm_split)
  elseif selected_option == "option4" then -- If option 3
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run → " .. entry_point,
            cmd = "time " .. output,                           -- run
        },},},})
    task:start()
    overseer.run_action(task, "open " .. toggleterm_split)
  end
end

return M
