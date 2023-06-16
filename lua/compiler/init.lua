-- This plugin is a wrapper for overseer
local uv = vim.loop
local cmd = vim.api.nvim_create_user_command
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local M = {}

M.setup = function(ctx)
  -- Setup options
  -- html_output = ctx.html_output
  -- hide_toolbar = ctx.hide_toolbar
  -- grace_period = ctx.hide_toolbar
  --
  -- -- Set default options
  -- if html_output == nil then
  --   local is_windows = vim.loop.os_uname().sysname == "Windows"
  --   if is_windows then -- windows
  --     html_output = "C:\\Users\\<username>\\AppData\\Local\\Temp\\markmap.html"
  --   else               -- unix
  --     html_output = "/tmp/markmap.html"
  --   end
  -- end
  --
  -- if hide_toolbar == true then
  --   hide_toolbar = "--no-toolbar"
  -- else
  --   hide_toolbar = nil
  -- end
  --
  -- if grace_period == nil then
  --   grace_period = 3600000 -- 60min
  -- end



  -- Setup commands -----------------------------------------------------------
  cmd("CompilerOpen", function()
    require("neocompiler.compiler").CompilerOpen()
  end, { desc = "Show a mental map of the current file" })

end

return M
