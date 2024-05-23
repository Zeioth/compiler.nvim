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
---and return them as a table.
---@param path string Path to the Makefile.
---@return table options A table like:
--- { { text: "Make all", value="all", bau = "make"}, { text: "Make hello", value="hello", bau = "make"} ...}
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
---and return them as a table.
---@param path string Path to the CMakeLists.txt file.
---@return table options A table like:
--- { { text: "CMake all", value="all", bau = "cmake"}, { text: "CMake hello", value="hello", bau = "cmake"} ...}
local function get_cmake_opts(path)
  local options = {}

  local file = io.open(path, "r")
  if file then
    local content = file:read("*all")
    file:close()

    -- Parse add_executable entries
    for target in content:gmatch("add_executable%s*%(%s*([%w_]+)") do
      table.insert(
        options,
        { text = "CMake " .. target, value = target, bau = "cmake" }
      )
    end

    -- Parse add_custom_target entries
    for target in content:gmatch("add_custom_target%s*%(%s*([%w_]+)") do
      table.insert(
        options,
        { text = "CMake " .. target, value = target, bau = "cmake" }
      )
    end
  end

  return options
end

--- Given a Mesonfile, parse all the options,
--- and return them as a table.
--- @param path string Path to the meson.build
--- @return table options A table like:
--- { { text = "Meson hello", value = "hello", description = "Print Hello, World!", bau = "meson" }, ...}
local function get_meson_opts(path)
  local options = {}

  local file = io.open(path, "r")
  if file then
    local content = file:read("*all")
    file:close()

    -- Parse executable entries
    for target in content:gmatch("executable%s*%(.-['\"]([%w_]+)['\"]") do
      table.insert(
        options,
        { text = "Meson " .. target, value = target, bau = "meson" }
      )
    end

    -- Parse custom_target entries
    for target in content:gmatch("custom_target%s*%(%s*'([^']+)'") do
      table.insert(
        options,
        { text = "Meson " .. target, value = target, bau = "meson" }
      )
    end
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

local function executeCommand(command)
  local output = vim.fn.system(command)
  return output
end

-- Function to parse tasks from the output
local function parseTasks(output)
  -- Check if output is a single line and contains only characters
  if output:find("[^\n\r]+") and not output:find("[^%a\n\r]") then
    local tasks = {}
    for task in output:gmatch("%S+") do
      table.insert(tasks, task)
    end
    return tasks
  else
    return {}
  end
end

local function isWindows()
  return os.getenv("OS") == "Windows_NT"
end

local function isTaskAlreadyAdded(options, task_name)
  for _, option in ipairs(options) do
    if option.value == task_name then
      return true
    end
  end
  return false
end

local function getGradleTasksCommandLine()
  local GRADLE_GLOBAL_COMMAND = "gradle tasks"
  local GRADLEW_UNIX_COMMAND = "./gradlew tasks"
  local GRADLEW_WINDOWS_COMMAND = "gradlew.bat tasks"
  local RUN_POWERSHELL_COMMAND = "powershell -c"

  local POWERSHELL_COMMAND =
  [[ | Out-String | Select-String -Pattern "(?sm)Application tasks(.*?)(?:\r?\n){2}" | ForEach-Object { $_.Matches.Groups[1].Value -split "\r?\n" | ForEach-Object -Begin { $skip = $true } { if (-not $skip) { ($_ -split "\s+", 2)[0] } $skip = $false } | Where-Object { $_ -notmatch "--" -and $_.Trim() -ne "" } }]]
  local AWK_COMMAND =
  " 2>&1 | awk '/Application tasks/,/^$/{if (!/^$/) print}' | awk 'NR > 2' | awk '!/--/ && NF {gsub(/ .*/, \"\", $0); print}' | sed '/^$/d'"

  local gradleOutput = ""
  local gradleCommand = ""

  if isWindows() then
    if vim.fn.filereadable("./gradlew.bat") then
      gradleCommand = RUN_POWERSHELL_COMMAND .. " '" .. GRADLEW_WINDOWS_COMMAND .. POWERSHELL_COMMAND .. "'"
    else -- Fallback to global gradle
      gradleCommand = RUN_POWERSHELL_COMMAND .. " '" .. GRADLE_GLOBAL_COMMAND .. POWERSHELL_COMMAND .. "'"
    end
  else -- Assume Unix
    if vim.fn.filereadable("./gradlew") then
      gradleCommand = GRADLEW_UNIX_COMMAND .. AWK_COMMAND
    else -- Fallback to global gradle
      gradleCommand = GRADLE_GLOBAL_COMMAND .. AWK_COMMAND
    end
  end

  gradleOutput = executeCommand(gradleCommand);

  return parseTasks(gradleOutput)
end


local function get_gradle_opts(path)
  local options = {}

  local file = io.open(path, "r")

  if not file then
    -- If the file with ".kts" extension doesn't exist, try without the extension
    local alternative_path = string.gsub(path, "%.kts$", "")
    file = io.open(alternative_path, "r")
  end

  if file then
    -- First parse the gradle tasks using the command line
    local tasks = getGradleTasksCommandLine()

    -- If the gradle command returns something, add the tasks to the options
    if tasks and #tasks > 0 then
      for _, task_name in ipairs(tasks) do
        if task_name == "" then
          break
        end
        table.insert(
          options,
          { text = "Gradle " .. task_name, value = task_name, bau = "gradle" }
        )
      end
    end

    -- Then parse the the tasks from file to get additional user-defined tasks if any
    local in_task = false
    local task_name = ""

    for line in file:lines() do
      -- Parse Kotlin DSL file
      local task_match = line:match('tasks%.register%s*%(?%s*"(.-)"%s*%)?%s*{')

      if task_match then
        in_task = true
        task_name = task_match

        if not isTaskAlreadyAdded(options, task_name) then
          table.insert(
            options,
            { text = "Gradle " .. task_name, value = task_name, bau = "gradle" }
          )
        end
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

          if not isTaskAlreadyAdded(options, task_name) then
            table.insert(
              options,
              { text = "Gradle " .. task_name, value = task_name, bau = "gradle" }
            )
          end
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

--- Given a package.json file, parse all the targets,
--- and return them as a table.
---
--- let g:NODEJS_PACKAGE_MANAGER can be defined to 'yarn' or 'npm' (default)
---@param path string Path to the package.json file.
---@return table options A table like:
--- { { text: "npm install", value="install", bau = "npm"}, { text: "npm start", value="start", bau = "npm"} ...}
local function get_nodejs_opts(path)
  local options = {}

  local file = io.open(path, "r")

  if file then
    local content = file:read "*all"
    file:close()

    -- parse package.json
    local package_json = {}
    local success, result = pcall(
      function() package_json = vim.fn.json_decode(content) end
    )
    if not success then
      -- Handle the error, such as invalid JSON format
      print("Error decoding JSON: " .. result)
      return options
    end

    -- Global: NODEJS_PACKAGE_MANAGER
    local success, package_manager =
        pcall(vim.api.nvim_get_var, "NODEJS_PACKAGE_MANAGER")
    if not success or package_manager == "" then package_manager = "npm" end

    -- Add parsed options to table "options"
    local scripts = package_json.scripts
    if scripts then
      -- Hardcode install/uninstall scripts
      table.insert(
        options,
        {
          text = package_manager:upper() .. " install",
          value = package_manager .. " install",
          bau = "nodejs",
        }
      )
      if package_manager == "npm" then
        table.insert(
          options,
          {
            text = package_manager:upper() .. " uninstall *",
            value = package_manager .. " uninstall *",
            bau = "nodejs",
          }
        )
      end

      -- Afterwards, add the scripts from package.json
      for script, _ in pairs(scripts) do
        table.insert(options, {
          text = package_manager:upper() .. " " .. script,
          value = package_manager .. " run " .. script,
          bau = "nodejs",
        })
      end
    end
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
  local working_dir = vim.fn.getcwd()
  local options = {}

  -- make
  vim.list_extend(options, get_makefile_opts(
    working_dir .. utils.os_path("/Makefile")
  ))

  -- cmake
  vim.list_extend(options, get_cmake_opts(
    working_dir .. utils.os_path("/CMakeLists.txt")
  ))

  -- meson
  vim.list_extend(options, get_meson_opts(
    working_dir .. utils.os_path("/meson.build")
  ))

  -- gradle
  vim.list_extend(options, get_gradle_opts(
    working_dir .. utils.os_path("/build.gradle.kts")
  ))

  -- nodejs
  vim.list_extend(options, get_nodejs_opts(
    working_dir .. utils.os_path("/package.json")
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

  if success then
    return bau
  else
    -- local error = "Build automation utilities \"" .. bau .. "\" not supported by the compiler."
    -- vim.notify(error, vim.log.levels.INFO, { title = "Build automation utilities unsupported" })
    return nil
  end
end

return M
