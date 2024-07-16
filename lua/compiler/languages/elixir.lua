--- Elixir language actions

local M = {}

--- Frontend - options displayed on telescope
M.options = {
  { text = "Run this file", value = "option1" },
  { text = "Mix run", value = "option2" },
  { text = "Run REPL", value = "option3" }
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local current_file = utils.os_path(vim.fn.expand('%:p'), true)             -- current file
  local final_message = "--task finished--"


  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Elixir compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run this file → " .. current_file,
          cmd = "elixir -r " .. current_file ..                              -- compile & run single file (bytecode)
                " && echo " .. current_file ..                               -- echo
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Elixir compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Mix run → \"./mix.exs\"",
          cmd = "mix clean " ..                                              -- clean
                " && mix run " ..                                            -- compile & run (bytecode)
                " && echo \"" .. final_message .. "\"",
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Elixir REPL",
      strategy = { "orchestrator",
        tasks = {{ name = "- Start REPL",
          cmd = "iex",                                                       -- run
          components = { "default_extended" }
        },},},})
    task:start()
  end
end

return M
