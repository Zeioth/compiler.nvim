--- ### Utils-bau for build automation utilities

--- Frontend compatilibity:
--- The parsers in this file return data in a format Telescope can undestand.
--- If you want to support other frontend, write an adapter function
--- to convert the data format returned by the parsers as needed.

local M = {}
local utils = require("compiler.utils")


-- PARSERS
-- Private functions to parse bau files.
-- ============================================================================

---Given a Makefile file, parse all the targets,
--- and return them as a table.
---@param path string Path to the Makefile.
---@return table options A table like:
--- { { text: "Make all", value="all", bau = "cmake"}, { text: "Make hello", value="hello", bau = "make"} ...}
local function get_makefile_opts(path)
  local options = {}

  -- Open the Makefile for reading
  local file = io.open(path, "r")

  if file then
    local in_target = false

    -- Iterate through each line in the Makefile
    for line in file:lines() do
      -- Check for lines starting with a target rule (e.g., "target: dependencies")
      local target = line:match "^(.-):"
      if target then
        in_target = true
        -- Exclude the ":" and add the option to the list with text and value fields
        table.insert(
          options,
          { text = "Make " .. target, value = target, bau = "make" }
        )
      elseif in_target then
        -- If we're inside a target block, stop adding options
        in_target = false
      end
    end

    -- Close the Makefile
    file:close()
  end

  return options
end

---Given a CMakeLists.txt file, parse all the targets,
--- and return them as a table.
---@param path string Path to the CMakeLists.txt file.
---@return table options A table like:
--- { { text: "CMake all", value="all", bau = "cmake"}, { text: "CMake hello", value="hello", bau = "cmake"} ...}
local function get_cmake_opts(path)
  local options = {}

  local file = io.open(path, "r")

  if file then
    local in_command = false

    for line in file:lines() do
      -- Parse 'add_executable' commands
      local target = line:match("^%s*add_executable%s*%(")
      if target then
        in_command = true
        target = line:match("(%b())")
        target = target:gsub("[%(%)]", "")

        -- Split the target string by spaces and take the first part
        target = target:match("(%S+)")

        table.insert(
          options,
          { text = "CMake " .. target, value = target, bau = "cmake" }
        )
      elseif in_command then
        in_command = false
      end

      -- Parse 'add_custom_target' commands
      local custom_target = line:match("^%s*add_custom_target%s*%(")
      if custom_target then
        in_command = true
        custom_target = line:match("(%b())")
        custom_target = custom_target:gsub("[%(%)]", "")

        -- Split the custom target string by spaces and take the first part
        custom_target = custom_target:match("(%S+)")

        table.insert(
          options,
          { text = "CMake " .. custom_target, value = custom_target, bau = "cmake" }
        )
      elseif in_command then
        in_command = false
      end
    end

    file:close()
  end

  return options
end

---Given a build.gradle.kts file, parse all the tasks,
---and return them as a table.
---
--- If the file is not found. It will fallback to build.gradle.
---@param path string Path to the build.gradle.kts file.
---@return table options A table like:
--- { { text: "Gradle all", value="all", bau = "gradle"}, { text: "Gradle hello", value="hello", bau = "gradle"} ...}
local function get_gradle_opts(path)
  local options = {}

  local file = io.open(path, "r")

  if not file then
    -- If the file with ".kts" extension doesn't exist, try without the extension
    local alternative_path = string.gsub(path, "%.kts$", "")
    file = io.open(alternative_path, "r")
    print(file)
  end

  if file then
    local in_task = false
    local task_name = ""

    for line in file:lines() do
      -- Parse Kotlin DSL file
      local task_match = line:match('tasks%.register%s*%(?%s*"(.-)"%s*%)?%s*{')

      if task_match then
        in_task = true
        task_name = task_match

        table.insert(
          options,
          { text = "Gradle " .. task_name, value = task_name, bau = "gradle" }
        )
      elseif in_task then
        local task_end = line:match("}")
        if task_end then
          in_task = false
          task_name = ""
        end
      else
        -- Parse Groovy DSL file
        task_match = line:match("%s*task%s+([%w_]+)%s*%{")
        if task_match then
          in_task = true
          task_name = task_match

          table.insert(
            options,
            { text = "Gradle " .. task_name, value = task_name, bau = "gradle" }
          )
        elseif in_task then
          local task_end = line:match("}")
          if task_end then
            in_task = false
            task_name = ""
          end
        end
      end
    end

    file:close()
  end

  return options
end





-- FRONTEND
-- Public functions to call from the frontend.
-- ============================================================================

---Function that call all bau function and combine the result in a table.
---@return table options A table that contain
--- the options of all bau available in the current working directory.
--- Empty table {} if none is found.
function M.get_bau_opts()
  local current_dir = vim.fn.expand("%:p:h")
  local options = {}

  -- make
  vim.list_extend(options, get_makefile_opts(
    current_dir .. utils.os_path("/Makefile")
  ))

  -- cmake
  vim.list_extend(options, get_cmake_opts(
    current_dir .. utils.os_path("/CMakeLists.txt")
  ))

  -- gradle
  vim.list_extend(options, get_gradle_opts(
    current_dir .. utils.os_path("/build.gradle.kts")
  ))

  return options
end

---Programatically require a bau backend,
--- responsible for running the action selected by the user in the frontend.
---@return table|nil bau The bau backend,
--- or nil, if ./bau/<bau>.lua doesn't exist.
function M.require_bau(bau)
  local local_path = debug.getinfo(1, "S").source:sub(2)
  local local_path_dir = local_path:match("(.*[/\\])")
  local module_file_path = utils.os_path(local_path_dir .. "bau/" .. bau .. ".lua")
  local success, bau = pcall(dofile, module_file_path)

  if success then return bau
  else
    -- local error = "Build automation utilities \"" .. bau .. "\" not supported by the compiler."
    -- vim.notify(error, vim.log.levels.INFO, { title = "Build automation utilities unsupported" })
    return nil
  end
end

return M
