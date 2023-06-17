--- ### Nvim compiler/runner

local M = {}

function M.show()
  -- dependencies
  actions = require "telescope.actions"
  state = require "telescope.actions.state"
  pickers = require "telescope.pickers"
  finders = require "telescope.finders"
  sorters = require "telescope.sorters"

  buffer = vim.api.nvim_get_current_buf()
  filetype = vim.api.nvim_buf_get_option(buffer, "filetype")
  options = {}

  local c = require "compiler.languages.c"

  -- We show different options on telescope depending the current language
  if filetype == "c" then options = c.options end
  if filetype == "cpp" then options = c.options end
  if filetype == "cs" then options = c.options end
  if filetype == "rust" then options = c.options end

  --- On option selected → Run action depending of the language
  local function on_option_selected(prompt_bufnr)
    local selection = state.get_selected_entry()
    actions.close(prompt_bufnr) -- Close Telescope on selection

    if selection then
      local selected_action = selection.value
      if filetype == "c" then c.action(selected_action) end
      if filetype == "cpp" then c.action(selected_action) end
      if filetype == "cs" then c.action(selected_action) end
      if filetype == "rust" then c.action(selected_action) end
    end
  end

  --- Show telescope
  local function open_telescope()
    pickers
      .new({}, {
        prompt_title = "Compiler",
        preview_title = "Actions",
        finder = finders.new_table {
          results = options,
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
