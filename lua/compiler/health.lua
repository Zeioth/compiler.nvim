-- On neovim you can run
-- :checkhealth compiler
-- To know possible causes in case compiler.nvim is not working correctly.

local M = {}

function M.check()
  vim.health.start("compiler.nvim")

  vim.health.info(
    "Neovim Version: v"
      .. vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\n]*")
  )

  if vim.version().prerelease then
    vim.health.warn "Neovim nightly is not officially supported and may have breaking changes."
  elseif vim.fn.has("nvim-0.10" == 1) then
    vim.health.ok("Using stable Neovim >= 0.10.0")
  else
    vim.health.error("Neovim >= 0.10.0 is required")
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
      cmd = "mono",
      type = "warn",
      msg = "Used to run C# programs compiled by csc.",
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
      cmd = "cargo",
      type = "warn",
      msg = "Used to call the rust compiler.",
    },
    {
      cmd = { "elixir" },
      type = "warn",
      msg = "Used to call the elixir compiler.",
    },
    {
      cmd = { "Rscript" },
      type = "warn",
      msg = "Used to call the r interpreter.",
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
      cmd = "node",
      type = "warn",
      mag = "Used to call the javascript interpreter.",
    },
    {
      cmd = "tsc",
      type = "warn",
      mag = "Used to transpile typescript to javascript. If you install it on your project, it will prevail over the global tsc executable.",
    },
    {
      cmd = { "swiftc" },
      type = "warn",
      msg = "Used to call the swift compiler.",
    },
    {
      cmd = { "swift" },
      type = "warn",
      msg = "Used to call the swift cli.",
    },
    {
      cmd = { "gfortran" },
      type = "warn",
      msg = "Used by compiler.nvim to compile fortran (optional)"
    },
    {
      cmd = { "fpm" },
      type = "warn",
      msg = "Used by compiler.nvim to compile fortran (optional)"
    },
    {
      cmd = { "go" },
      type = "warn",
      msg = "Used to call the go compiler.",
    },
    {
      cmd = "kotlin",
      type = "warn",
      msg = "Used to call the kotlin compiler.",
    },
    {
      cmd = "kotlinc",
      type = "warn",
      msg = "Used to call the kotlin compiler.",
    },
    {
      cmd = "dart",
      type = "warn",
      msg = "Used to call the dart compiler.",
    },
    {
      cmd = "flutter",
      type = "warn",
      msg = "Used to call the dart flutter compiler.",
    },
    {
      cmd = "perl",
      type = "warn",
      msg = "Used to call the perl interpreter.",
    },
    {
      cmd = "zig",
      type = "warn",
      msg = "Used to call the zig compiler.",
    },
    {
      cmd = "make",
      type = "warn",
      msg = "Used to call the make interpreter.",
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
      vim.health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      vim.health[program.type](
        ("`%s` is not installed: %s"):format(name, program.msg)
      )
    end
  end
end

return M

