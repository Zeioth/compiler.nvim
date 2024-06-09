--- meson.build bau actions

local M = {}

-- Backend - overseer tasks performed on option selected
function M.action(option)
  local overseer = require("overseer")
  local final_message = "--task finished--"

  -- Global: MESON_BUILD_DIR
  local success, build_dir = pcall(vim.api.nvim_get_var, 'MESON_BUILD_DIR')
  if not success or build_dir == "" then build_dir = './build' end

  -- Global: MESON_BUILD_TYPE
  local success, build_type = pcall(vim.api.nvim_get_var, 'MESON_BUILD_TYPE')
  if not success or build_type == "" then build_type = '"debug"' end

  -- Global: MESON_CLEAN_FIRST
  local clean_first_arg = ""
  local _, clean_first = pcall(vim.api.nvim_get_var, 'MESON_CLEAN_FIRST')
  if clean_first == "true" then clean_first_arg = "--wipe" end

  -- Run command
  local cmd_setup = "meson setup " .. clean_first_arg .. " \"" .. build_dir .. "\" --buildtype=" .. build_type
  local cmd_build = "meson compile -C \"" .. build_dir .. "\" " .. option
  local cmd_target = "ninja -C " .. build_dir .. " " .. option
  print(cmd_build)
  local task = overseer.new_task({
    name = "- Meson interpreter",
    strategy = { "orchestrator",
      tasks = {{ name = "- Run Meson → " .. option,
        cmd = "mkdir -p \"" .. build_dir .. "\"" ..
              " && " .. cmd_setup ..                                         -- Setup
              " && " .. cmd_build ..                                         -- Build target from the 'build' directory.
              --" && " .. cmd_target ..                                      -- Run target
              " && echo \"" .. cmd_setup .. " && " .. cmd_build  .. "\"" ..  -- echo
              " && echo \"" .. final_message .. "\"",
        components = { "default_extended" }
      },},},})
  task:start()
end

return M

