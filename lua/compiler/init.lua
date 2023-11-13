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
    -- If the user didn't select an option yet, send a notification.
    if _G.compiler_redo == nil then
      vim.notify("Open the compiler and select an option before doing redo.",
        vim.log.levels.INFO, { title = "Compiler.nvim" }
      )
      return
    end
    -- If filetype is not the same as when the option was selected, send a notification.
    local current_filetype = vim.bo.filetype
    if _G.compiler_redo_filetype ~= current_filetype then
      vim.notify("You are on a different language now. Open the compiler and select an option before doing redo.", vim.log.levels.INFO, {
        title = "Compiler.nvim"
      })
      return
    end
    -- Redo
    local language = require('compiler.utils').require_language(current_filetype)
    if not language then language = require("compiler.languages.make") end
    language.action(_G.compiler_redo)
  end, { desc = "Redo the last selected compiler option" })

  cmd("CompilerStop", function()
    vim.notify("SUCCESS - All tasks have been disposed.", vim.log.levels.INFO, {
      title = "Compiler.nvim"
    })
    local overseer = require("overseer")
    local tasks = overseer.list_tasks({ unique = false })
    for _, task in ipairs(tasks) do
      overseer.run_action(task, "dispose")
    end
  end, { desc = "Dispose all tasks running in the compiler" })
end

return M
