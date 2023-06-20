--- ### Commands for compiler.nvim
-- This plugin is just a wrapper for overseer.nvim that displays
-- tasks for compiling/running your current project based on the filetype
-- of the file you are currently editing.

local uv = vim.loop
local cmd = vim.api.nvim_create_user_command
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local M = {}

M.setup = function(ctx)
  cmd("CompilerOpen", function()
    require("compiler.telescope").show()
  end, { desc = "Open the compiler" })

  cmd("CompilerToggleResults", function()
    vim.cmd("OverseerToggle")
  end, { desc = "Toggle the compiler results" })
end

return M
