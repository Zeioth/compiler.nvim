--- Swift language actions

local M = {}

--- Frontend  - options displayed on telescope
-- TODO: add support for other configurations (beyond debug and release)
M.options = {
  { text = "Run debug configration", value = "option1" },
  { text = "Run release configuration", value = "option2" },
  { text = "Build debug configuration", value = "option3" },
  { text = "Build release configuration", value = "option4" },
}

--- Backend - overseer tasks performed on option selected
function M.action(selected_option)
  local utils = require("compiler.utils")
  local overseer = require("overseer")
  local final_message = "--task finished--"

  local package_file = assert(utils.os_path(vim.fn.getcwd() .. "/Package.swift"))   -- working_directory/Package.swift
  local package = M.parse_package_file(package_file)

  -- TODO: add support for selecting a target
  local target_name = package.package_name

  if selected_option == "option1" then
    local task = overseer.new_task({
      name = "- Swift compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run target → " .. target_name,
          cmd = "swift run " .. target_name .. " -c debug" ..    -- build target 
                " && echo '" .. final_message .. "'"                      -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option2" then
    local task = overseer.new_task({
      name = "- Swift compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Run target → " .. target_name,
          cmd = "swift run " .. target_name .. " -c release" ..    -- build target 
                " && echo '" .. final_message .. "'"                        -- echo
        },},},})
    task:start()
    vim.cmd("OverseerOpen")
  elseif selected_option == "option3" then
    local task = overseer.new_task({
      name = "- Swift compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build target → " .. target_name,
          cmd = "swift build --target " .. target_name .. " -c debug" ..    -- build target 
                " && echo '" .. final_message .. "'"                        -- echo
        },},},})
    task:start()
  elseif selected_option == "option4" then
    local task = overseer.new_task({
      name = "- Swift compiler",
      strategy = { "orchestrator",
        tasks = {{ "shell", name = "- Build and run target → ",
          cmd = "swift build --target " .. target_name .. " -c release" ..    -- build target 
                " && echo '" .. final_message .. "'"                          -- echo
        },},},})
    task:start()
  end

end

--- Extracts targets from Package.swift file
--- Example format:
--- let package = Package(
---   name: "example",
---   targets: [
---     .executableTarget(name: "example")
---   ]
---  )
---
---@param file_path string
---@return table
M.parse_package_file = function(file_path)
  local file = assert(io.open(file_path, "r"))
  local content = file:read("*a")
  file:close()

  local packageDeclaration = content:match("Package%b()")
  local package_name = nil
  if packageDeclaration then
      package_name = packageDeclaration:match('name:%s*"([^"]+)"')
  end

  local targets = {}
  for target in content:gmatch('.executableTarget%(name:%s*"([^"]+)"%)') do
      table.insert(targets, target)
  end

  return {
    package_name = package_name,
    targets = targets,
  }
end


return M
