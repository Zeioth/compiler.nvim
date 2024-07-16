--- Gleam language actions

local M = {}

-- Frontend - options displayed on telescope
M.options = {
  { text = "Build and run program", value = "option1" },
  { text = "Build program", value = "option2" },
  { text = "Run program", value = "option3" },
}

-- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Gleam compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build & run program → " .. "\"./gleam.toml\"",
          cmd = "gleam build " ..                                            -- compile
                " && gleam run" ..                                           -- run
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Gleam compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Build program → " .. "\"./gleam.toml\"",
          cmd = "gleam build " ..                                            -- compile
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Gleam compiler",
      strategy = { "orchestrator",
        tasks = {{ name = "- Run program → " .. "\"./gleam.toml\"",
          cmd = "gleam run " ..                                              -- compile
                " && echo \"" .. final_message .. "\"",                      -- echo
          components = { "default_extended" }
        },},},})
    task:start()
   end
end

return M


