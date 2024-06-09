--- Build.gradle bau actions

local M = {}
local utils = require("compiler.utils")

local cmd = utils.os_path("./gradlew")
local filename = "gradlew"
local is_gradlew = vim.fn.filereadable(cmd) == 1

-- Determine cmd prevalence: "gradlew > gradle.kts > gradle"
if not is_gradlew then
  cmd = "gradle"
  local kts_path = utils.os_path("./build.gradle.kts")
  local is_kts = vim.fn.filereadable(kts_path) == 1
  if is_kts then filename = "build.gradle.kts"
  else filename = "build.gradle" end
end

-- Global: GRADLE_BUILD_TYPE
local success, build_type = pcall(vim.api.nvim_get_var, 'GRADLE_BUILD_TYPE')
if not success then build_type = "" end
build_type = string.upper(string.sub(build_type, 1, 1)) .. string.sub(build_type, 2) -- Enforce first letter is capitalized

-- Backend - overseer tasks performed on option selected
function M.action(option)
  local overseer = require("overseer")
  local final_message = "--task finished--"
  local task = overseer.new_task({
    name = "- Gradle interpreter",
    strategy = { "orchestrator",
      tasks = {{ name = "- " .. filename ..  " → " .. cmd .. " " .. option .. build_type,
        cmd = cmd .. " " .. option .. build_type ..                          -- run
              " && echo " .. cmd .. " "  .. option .. build_type ..          -- echo
              " && echo \"" .. final_message .. "\"",
        components = { "default_extended" }
      },},},})
  task:start()
end

return M
