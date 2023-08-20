--- ### Utils for compiler.nvim

local M = {}

--- Recursively searches for files with the given name
--  in all directories under start_dir.
---@param start_dir string
---@param file_name string
---@return table files Empty table if no files found.
function M.find_files(start_dir, file_name)
  local files = {}

  -- Create the find command with appropriate flags for recursive searching
  local find_command
  if package.config:sub(1, 1) == "\\" then -- Windows
    find_command = string.format('powershell.exe -Command "Get-ChildItem -Path \\"%s\\" -Recurse -Filter \\"%s\\" -File -Exclude \\".git\\" -ErrorAction SilentlyContinue"', start_dir, file_name)
  else -- UNIX-like systems
    find_command = string.format('find "%s" -type d -name ".git" -prune -o -type f -name "%s" -print 2>/dev/null', start_dir, file_name)
  end

  -- Execute the find command and capture the output
  local pipe = io.popen(find_command, "r")
  if pipe then
    for file_path in pipe:lines() do
      table.insert(files, file_path)
      --print("Found file:", file_path)
    end
    pipe:close()
  end

  return files
end

--- Search recursively, starting by the directory
--- of the entry_point file. Return files matching the pattern.
---@param entry_point string Entry point file of the program.
---@param pattern string File extension to search.
---@return string files_as_string Files separated by a space.
---@usage find_files_to_compile("/path/to/main.c", "*.c")
function M.find_files_to_compile(entry_point, pattern)
  local entry_point_dir = vim.fn.fnamemodify(entry_point, ":h")
  local files = M.find_files(entry_point_dir, pattern)
  local files_as_string = table.concat(files ," ")

  return files_as_string
end

-- Parse the solution file and extract variables.
---@param file_path string Path of the solution file to read.
---@return table config A table like { {entry_point, ouptput, ..} .. }
function M.parse_solution_file(file_path)
  local file = assert(io.open(file_path, "r"))  -- Open the file in read mode
  local config = {}  -- Initialize an empty Lua table to store the variables
  local current_entry = nil  -- Variable to track the current entry being processed

  for line in file:lines() do
    if not (line:match("^%s*#") or line:match("^%s*$")) then -- ignore comments and empty lines
      local entry = line:match("%[([^%]]+)%]")  -- Check if the line represents a new entry
      if entry then
        current_entry = entry  -- Update the current entry being processed
        config[current_entry] = {}  -- Initialize a sub-table for the current entry
      else
        local key, value = line:match("([^=]+)%s-=%s-(.+)")  -- Extract key-value pairs
        if key and value and current_entry then
          value = value:gsub("^%s*[\"'](.+)[\"']%s*$", "%1")  -- Remove surrounding quotes if present
          config[current_entry][vim.trim(key)] = vim.trim(value)  -- Store the variable in the table
        end
      end
    end
  end

  file:close()  -- Close the file
  return config  -- Return the parsed config
end

--- Programatically require the backend for the current language.
--- This function is compatible with Unix and Windows.
---@return module language If languages/<filetype>.lua doesn't exist,
--         send a notification and return nil.
function M.require_language(filetype)
  local local_path = debug.getinfo(1, "S").source:sub(2)
  local local_path_dir = local_path:match("(.*[/\\])")
  local module_file_path = M.os_path(local_path_dir .. "languages/" .. filetype .. ".lua")
  local success, language = pcall(dofile, module_file_path)

  if success then return language
  else
    -- local error = "Filetype \"" .. filetype .. "\" not supported by the compiler."
    -- vim.notify(error, vim.log.levels.INFO, { title = "Language unsupported" })
    return nil
  end
end

--- Function that returns true if a file exists in physical storage
---@return bool
function M.file_exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type == "file"
end

--- Function that returns the path of the .solution file if exists in the current
--- working directory's root, or nil otherwise.
---@return string|nil
function M.get_solution_file()
  if M.file_exists(".solution.toml") then
    return  M.os_path(vim.fn.getcwd() .. "/.solution.toml")
  elseif M.file_exists(".solution") then
    return  M.os_path(vim.fn.getcwd() .. "/.solution")
  else
    return nil
  end
end

--- Given a string, convert 'slash' to 'inverted slash' if on windows, and vice versa on UNIX.
-- Then return the resulting string.
---@param path string
---@return string
function M.os_path(path)
  if path == nil then return nil end
  -- Get the platform-specific path separator
  local separator = package.config:sub(1,1)
  return string.gsub(path, '[/\\]', separator)
end

return M
