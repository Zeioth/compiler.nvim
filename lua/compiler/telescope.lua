--- ### Frontend for compiler.nvim

local M = {}

function M.show()
  -- dependencies
  actions = require "telescope.actions"
  state = require "telescope.actions.state"
  pickers = require "telescope.pickers"
  finders = require "telescope.finders"
  sorters = require "telescope.sorters"
  utils = require("compiler.utils")

  local buffer = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(buffer, "filetype")

  -- programatically require the backend for the current language
  language = utils.requireLanguage(filetype)
  if not language then return end -- if we don't support the language, exit

  --- On option selected → Run action depending of the language
  local function on_option_selected(prompt_bufnr)
    actions.close(prompt_bufnr) -- Close Telescope on selection
    local selection = state.get_selected_entry()
    if selection then language.action(selection.value) end
  end

  --- Show telescope
  local function open_telescope()
    pickers
      .new({}, {
        prompt_title = "Compiler",
        results_title = "Options",
        finder = finders.new_table {
          results = language.options,
          entry_maker = function(entry)
            return {
              display = entry.text,
              value = entry.value,
              ordinal = entry.text,
            }
          end,
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
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
