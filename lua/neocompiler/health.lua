-- On neovim you can run
-- :checkhealth markmap
-- To know possible causes in case markmap.nvim is nor working correctly.

local M = {}

-- TODO: remove deprecated method check after dropping support for neovim v0.9
local health = {
  start = vim.health.start or vim.health.report_start,
  ok = vim.health.ok or vim.health.report_ok,
  warn = vim.health.warn or vim.health.report_warn,
  error = vim.health.error or vim.health.report_error,
  info = vim.health.info or vim.health.report_info,
}

function M.check()
  health.start "markmap.nvim"

  health.info(
    "Neovim Version: v"
      .. vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\n]*")
  )

  if vim.version().prerelease then
    health.warn "Neovim nightly is not officially supported and may have breaking changes"
  elseif vim.fn.has "nvim-0.8" == 1 then
    health.ok "Using stable Neovim >= 0.8.0"
  else
    health.error "Neovim >= 0.8.0 is required"
  end

  local programs = {
    {
      cmd = "git",
      type = "error",
      msg = "Used for core functionality such as cloning markmap.nvim",
    },
    {
      cmd = { "node" },
      type = "error",
      msg = "Used for core functionality such as running markmap-cli",
    },
    {
      cmd = { "yarn" },
      type = "warn",
      msg = "Used to install markmap-cli. This operation can also be performed using npm instead, or even manually. See README.md for more info:/nhttps://github.com/Zeioth/markmap.nvim",
    },
    {
      cmd = "markmap",
      type = "error",
      msg = "Used to for the main functionality of the plugin. markmap-cli must be executable in a terminal.",
    },
  }

  for _, program in ipairs(programs) do
    if type(program.cmd) == "string" then program.cmd = { program.cmd } end
    local name = table.concat(program.cmd, "/")
    local found = false
    for _, cmd in ipairs(program.cmd) do
      if vim.fn.executable(cmd) == 1 then
        name = cmd
        found = true
        break
      end
    end

    if found then
      health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      health[program.type](
        ("`%s` is not installed: %s"):format(name, program.msg)
      )
    end
  end
end

return M

