--- ### Shared utilities for compiler.nvim pickers

local M = {}

--- Validates that the current working directory is not the home directory
--- @return boolean true if valid, false if invalid (also shows notification)
function M.validate_working_directory()
  if vim.loop.os_homedir() == vim.loop.cwd() then
    vim.notify(
      "You must :cd your project dir first.\nHome is not allowed as working dir.",
      vim.log.levels.WARN,
      {
        title = "Compiler.nvim",
      }
    )
    return false
  end
  return true
end

--- Prepares compiler options by gathering language and BAU options
--- @return table { language, options, filetype }
function M.prepare_compiler_options()
  local utils = require("compiler.utils")
  local utils_bau = require("compiler.utils-bau")

  local buffer = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = buffer })

  -- Programatically require the backend for the current language.
  local language = utils.require_language(filetype)

  -- On unsupported languages, default to make.
  if not language then language = utils.require_language("make") or {} end

  -- Also show options discovered on Makefile, Cmake... and other bau.
  if not language.bau_added then
    language.bau_added = true
    local bau_opts = utils_bau.get_bau_opts()

    -- Insert a separator for every bau.
    local last_bau_value = nil
    for _, item in ipairs(bau_opts) do
      if last_bau_value ~= item.bau then
        table.insert(language.options, { text = "", value = "separator" })
        last_bau_value = item.bau
      end
      table.insert(language.options, item)
    end
  end

  -- Add numbers in front of the options to display.
  local index_counter = 0
  for _, option in ipairs(language.options) do
    if option.value ~= "separator" then
      index_counter = index_counter + 1
      option.text = index_counter .. " - " .. option.text
    end
  end

  return {
    language = language,
    options = language.options,
    filetype = filetype,
  }
end

--- Executes the selected compiler option
--- @param selected_value string The value of the selected option
--- @param selected_text string The display text of the selected option
--- @param language_options table The full options table
--- @param filetype string The current filetype
function M.execute_selection(
  selected_value,
  selected_text,
  language_options,
  language,
  filetype
)
  if selected_value == "" or selected_value == "separator" then return end

  local utils_bau = require("compiler.utils-bau")

  -- Do the selected option belong to a build automation utility?
  local bau = nil
  for _, value in ipairs(language_options) do
    if value.text == selected_text or value.value == selected_value then
      bau = value.bau
      break
    end
  end

  if bau then -- call the bau backend.
    bau = utils_bau.require_bau(bau)
    if bau then bau.action(selected_value) end
    -- then
    -- clean redo (language)
    _G.compiler_redo_selection = nil
    -- save redo (bau)
    _G.compiler_redo_bau_selection = selected_value
    _G.compiler_redo_bau = bau
  else -- call the language backend.
    language.action(selected_value)
    -- then
    -- save redo (language)
    _G.compiler_redo_selection = selected_value
    _G.compiler_redo_filetype = filetype
    -- clean redo (bau)
    _G.compiler_redo_bau_selection = nil
    _G.compiler_redo_bau = nil
  end
end

--- Creates items and mapping for vim.ui.select (filters out separators)
--- @param language_options table The full options table
--- @return table { items, item_map }
function M.create_select_items(language_options)
  local items = {}
  local item_map = {}

  for _, option in ipairs(language_options) do
    if option.value ~= "separator" then
      table.insert(items, option.text)
      item_map[option.text] = { value = option.value, bau = option.bau }
    end
  end

  return { items = items, item_map = item_map }
end

return M
