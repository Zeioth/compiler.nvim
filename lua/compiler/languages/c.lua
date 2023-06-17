--- c language actions

local M = {}

-- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Build and run program", value = "option1" },
  { text = "2 - Build progrm", value = "option2" },
  { text = "3 - Run program", value = "option3" },
  { text = "4 - Make", value = "option4" }
}

-- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local entry_point = vim.fn.getcwd() .. "/main.c"     -- working_directory/main.c
  local output_dir = vim.fn.getcwd() .. "/bin/"        -- working_directory/bin/
  local output = vim.fn.getcwd() .. "/bin/program"     -- working_directory/bin/program
  local final_message = "--task finished--"

  if selected_option == "option1" then  -- If option 1
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",

        tasks = {{ "shell", name = "- Build & run program → " .. entry_point,
          cmd = "rm -rf " .. output_dir ..                                   -- clean
                " && mkdir -p " .. output_dir ..                             -- mkdir
                " && gcc " .. entry_point .. " -o " .. output .. " -Wall" .. -- compile
                " && time " .. output ..                                     -- run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
    -- overseer.run_action(task, "open hsplit") → Simplified summary
  elseif selected_option == "option2" then -- If option 2
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build program → " .. entry_point,
          cmd = "rm -rf " .. output_dir ..                                   -- clean
                " && mkdir -p " .. output_dir ..                             -- mkdir
                " && gcc " .. entry_point .. " -o " .. output .. " -Wall" .. -- compile
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then -- If option 3
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = "time " .. output ..                                       -- run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option 4" then -- If option 3
    local task = overseer.new_task({
      name = "- C compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run program → " .. entry_point,
            cmd = "time make Makefile" .. output ..                          -- run
                " && echo '" .. final_message .. "'"                         -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")

  end
end

return M
