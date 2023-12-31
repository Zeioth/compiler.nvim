--- Elixir language actions

local M = {}

--- Frontend  - options displayed on telescope
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Mix run", value = "option2" },
  { text = "Run REPL", value = "option3" }
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
        tasks = {{ "shell", name = "- Mix run → mix.exs",
          cmd = "mix clean " ..                                                      -- clean
                " && mix run " ..                                                    -- compile & run (bytecode)
                " && echo '" .. final_message .. "'"
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Elixir REPL",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Start REPL",
          cmd = "iex"                                                        -- run
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  end
end

return M
