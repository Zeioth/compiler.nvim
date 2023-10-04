--- Elixir language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "1 - Run this file", value = "option1" },
  { text = "2 - Mix run", value = "option2" },
  { text = "3 - Run REPL", value = "option3" },
  { text = "4 - Run Makefile", value = "option4" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local current_file = vim.fn.expand('%:p')                                  -- current file
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Elixir compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run this file → " .. current_file,
          cmd = "elixir -r " .. current_file ..                                       -- compile & run single file (bytecode)
                " && echo " .. current_file ..                                        -- echo
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Elixir compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build & run program → ./mix.exs",
          cmd = "mix clean " ..                                                      -- clean
                " && mix run " ..                                                    -- compile & run (bytecode)
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option4" then
    local task = overseer.new_task({
      name = "- Elixir REPL",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Start REPL",
          cmd = "iex"                                                        -- run
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option5" then
    require("compiler.languages.make").run_makefile()                        -- run
  end
end

return M
