--- ### Commands for compiler.nvim
-- This plugin is just a wrapper for overseer.nvim that displays
-- tasks for compiling/running your current project based on the filetype
-- of the file you are currently editing.

local cmd = vim.api.nvim_create_user_command
local M = {}

M.setup = function(ctx)
  cmd("CompilerOpen", function()
    require("compiler.telescope").show()
  end, { desc = "Open the compiler" })

  cmd("CompilerToggleResults", function()
    vim.cmd("OverseerToggle")
  end, { desc = "Toggle the compiler results" })

  cmd("CompilerRedo", function()
    -- Only allow redo if filetype is the same as when the option was selected.
    local current_filetype = vim.bo.filetype
    if _G.compiler_redo_filetype ~= current_filetype then return end
    local language = utils.requireLanguage(current_filetype)
    if not language then language = require("compiler.languages.make") end
    language.action(_G.compiler_redo)
  end, { desc = "Redo the last selected compiler option" })
end

return M
