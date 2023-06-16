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

return M
