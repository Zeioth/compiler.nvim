--- ### Frontend for compiler.nvim

local M = {}

function M.show()
  local picker_util = require("compiler.picker-util")

  -- Validate working directory
  if not picker_util.validate_working_directory() then return end

  -- Dependencies
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local state = require("telescope.actions.state")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")

  -- Prepare compiler options
  local compiler_data = picker_util.prepare_compiler_options()
  local language = compiler_data.language
  local language_options = compiler_data.options
  local filetype = compiler_data.filetype

  -- RUN ACTION ON SELECTED
  -- ========================================================================

  --- On option selected → Run action depending of the language.
  local function on_option_selected(prompt_bufnr)
    actions.close(prompt_bufnr) -- Close Telescope on selection
    local selection = state.get_selected_entry()

    if selection then
      picker_util.execute_selection(
        selection.value,
        selection.display,
        language_options,
        language,
        filetype
      )
    end
  end

  -- SHOW TELESCOPE
  -- ========================================================================
  local function open_telescope()
    pickers
      .new({}, {
        prompt_title = "Compiler",
        results_title = "Options",
        finder = finders.new_table({
          results = language_options,
          entry_maker = function(entry)
            return {
              display = entry.text,
              value = entry.value,
              ordinal = entry.text,
            }
          end,
        }),
        sorter = conf.generic_sorter(),
        attach_mappings = function(_, map)
          map(
            "i",
            "<CR>",
            function(prompt_bufnr) on_option_selected(prompt_bufnr) end
          )
          map(
            "n",
            "<CR>",
            function(prompt_bufnr) on_option_selected(prompt_bufnr) end
          )
          return true
        end,
      })
      :find()
  end
  open_telescope() -- Entry point
end

return M
