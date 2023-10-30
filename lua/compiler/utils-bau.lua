--- ### Utils-bau for build automation systems

--- Frontend compatilibity:
--- The parsers in this file return data in a format Telescope can undestand.
--- If you want to support other frontend, write an adapter function
--- to convert the data format returned by the parsers as needed.

local M = {}
local utils = require("compiler.utils")


-- PARSERS
-- Private functions to parse bau files.
-- ============================================================================

---Given a file, open the makefile, extract all the options,
-- and return them as a table.
---@param path string Path to the Makefile.
---@return table options A table like:
--- { { text: "my option", value="all" bau = "make"}, { text: "another option", value="hello", "make"} ...}
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

  vim.list_extend(
    options,
    get_makefile_opts(
      current_dir .. utils.os_path("/Makefile")
    )
  )

  return options
end

---Programatically require a bau backend,
-- responsible for running the action selected by the user in the frontend.
---@return table|nil bau The bau backend,
--- or nil, if ./bau/<bau>.lua doesn't exist.
function M.require_bau(bau)
  local local_path = debug.getinfo(1, "S").source:sub(2)
  local local_path_dir = local_path:match("(.*[/\\])")
  local module_file_path = utils.os_path(local_path_dir .. "bau/" .. bau .. ".lua")
  local success, bau = pcall(dofile, module_file_path)

  if success then return bau
  else
    -- local error = "Build automation system \"" .. bau .. "\" not supported by the compiler."
    -- vim.notify(error, vim.log.levels.INFO, { title = "Build automation system unsupported" })
    return nil
  end
end

return M
