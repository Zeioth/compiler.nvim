-- On neovim you can run
-- :checkhealth compiler
-- To know possible causes in case compiler.nvim is nor working correctly.

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
  health.start "compiler.nvim"

  health.info(
    "Neovim Version: v"
    .. vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\n]*")
  )

  if vim.version().prerelease then
    health.warn "Neovim nightly is not officially supported and may have breaking changes."
  elseif vim.fn.has "nvim-0.8" == 1 then
    health.ok "Using stable Neovim >= 0.8.0"
  else
    health.error "Neovim >= 0.8.0 is required"
  end

  local programs = {
    {
      cmd = "git",
      type = "error",
      msg = "Used for core functionality such as cloning compiler.nvim",
    },
    {
      cmd = "gcc",
      type = "warn",
      msg = "Used to call the C compiler.",
    },
    {
      cmd = "g++",
      type = "warn",
      msg = "Used to call the C++ compiler.",
    },
    {
      cmd = "csc",
      type = "warn",
      msg = "Used to call the C# compiler.",
    },
    {
      cmd = "dotnet",
      type = "warn",
      msg = "Used to call the C# compiler for .csproj files.",
    },
    {
      cmd = "javac",
      type = "warn",
      msg = "Used to call the java compiler.",
    },
    {
      cmd = "nasm",
      type = "warn",
      msg = "Used to call the assembly compiler.",
    },
    {
      cmd = "rustc",
      type = "warn",
      msg = "Used to call the rust compiler.",
    },
    {
      cmd = "python",
      type = "warn",
      msg = "Used to call the python interpreter.",
    },
    {
      cmd = "nuitka3",
      type = "warn",
      msg = "Used to call the python machine code compiler.",
    },
    {
      cmd = "pyinstaller",
      type = "warn",
      msg = "Used to call the python bytecode compiler.",
    },
    {
      cmd = "ruby",
      type = "warn",
      msg = "Used to call the ruby interpreter.",
    },
    {
      cmd = "make",
      type = "warn",
      msg = "Used to call the make interpreter.",
    },
    {
      cmd = "tsc",
      type = "warn",
      mag = "Used to call the typescript compiler.",
    },
    {
      cmd = "ts-node",
      type = "warn",
      msg = "Used to call the typescript interpreter.",
    }
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
