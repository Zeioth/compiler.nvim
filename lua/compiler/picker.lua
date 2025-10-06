--- ### Picker frontend for compiler.nvim
-- Automatically detects and uses telescope.nvim or falls back to vim.ui.select

local M = {}

function M.show()
  local telescope_ok = pcall(require, "telescope")

  if telescope_ok then
    require("compiler.telescope").show()
  else
    -- Fallback to vim.ui.select implementation
    local picker_util = require("compiler.picker-util")

    -- Validate working directory
    if not picker_util.validate_working_directory() then return end

    -- Prepare compiler options
    local compiler_data = picker_util.prepare_compiler_options()
    local language = compiler_data.language
    local options = compiler_data.options
    local filetype = compiler_data.filetype

    -- Create items for vim.ui.select
    local select_data = picker_util.create_select_items(options)
    local items = select_data.items
    local item_map = select_data.item_map

    -- Show vim.ui.select
    vim.ui.select(items, {
      prompt = "Compiler: ",
    }, function(choice)
      if not choice then return end
      local selected = item_map[choice]
      if not selected then return end

      picker_util.execute_selection(
        selected.value,
        choice,
        options,
        language,
        filetype
      )
    end)
  end
end

return M
