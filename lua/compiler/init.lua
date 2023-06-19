-- This plugin is a wrapper for overseer
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
