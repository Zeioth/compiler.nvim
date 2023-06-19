--- ### Nvim compiler/runner

local M = {}


--- Function to recursively search for files with the given name
function M.find_files(start_dir, target_name)
  local files = {}
  local current_files = vim.fn.readdir(start_dir)
  for _, file in ipairs(current_files) do
    local file_path = start_dir .. '/' .. file
    local file_type = vim.fn.getftype(file_path)
    if file_type == 'file' and file == target_name then
      table.insert(files, file_path)
    elseif file_type == 'directory' and file ~= '.' and file ~= '..' then
      find_files(file_path, target_name, files)
    end
  end

  return files
end

-- Function to parse the config file and extract variables
function M.parseConfigFile(filePath)
  local file = assert(io.open(filePath, "r"))  -- Open the file in read mode
  local collection = {}  -- Initialize an empty Lua table to store the variables
  local currentEntry = nil  -- Variable to track the current entry being processed

  for line in file:lines() do
    local entry = line:match("%[([^%]]+)%]")  -- Check if the line represents a new entry
    if entry then
      currentEntry = entry  -- Update the current entry being processed
      collection[currentEntry] = {}  -- Initialize a sub-table for the current entry
    else
      local key, value = line:match("([^=]+)%s-=%s-(.+)")  -- Extract key-value pairs
      if key and value and currentEntry then
        collection[currentEntry][key:trim()] = value:trim()  -- Store the variable in the collection
      end
    end
  end

  file:close()  -- Close the file
  return collection  -- Return the parsed collection
end

-- Function that returns true if a file exists in physical storage
function M.fileExists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat and stat.type == "file"
end

return M
