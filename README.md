# WIP: Please be patient, not ready for usage yet 
Neovim compiler capable of building and running the next languages without the need of configuring anything

* c
* c++
* c#
* rust
* python

## How to install
lazy.nvim package manager
```lua
{
  "https://github.com/Zeioth/compiler.nvim",
  dependenciens = { "stevearc/overseer.nvim" }
  event="VeryLazy",
  config = function(_, opts) require("compiler").setup(opts) end,
},
{
  "stevearc/overseer.nvim",
  event="VeryLazy",
  opts = {
    -- Tasks are disposed 5 minutes after running to free resources.
    -- If you need to close a task inmediatelly:
    -- press ENTER in the menu you see after compiling on the task you want to close.
    task_list = {
      direction = "bottom",
      min_height = 25,
      max_height = 25,
      default_detail = 1,
      bindings = {
        ["q"] = function() vim.cmd("OverseerClose") end ,
      }
    }
  },
  config = function(_, opts) require("overseer").setup(opts) end,
},
```
mappings (optional)
TODO: Instead of giving mapings, make a table with the exposed commands
```
-- Open compiler
vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', function() require "compiler.telescope".show() end, { noremap = true, silent = true })

-- Toggle output resume
vim.api.nvim_buf_set_keymap(0, 'n', '<S-F6>',   function() vim.cmd("OverseerToggle") end, { noremap = true, silent = true })
```

## How to use
Press `F6` to open the compiler.

Press `q` to close the results after you are done.

> compiler.nvim will look for the conventional entry point file for the current lenguage you are using. To achieve this, it searches it in your current working directory for the next files

  * c: `main.c`
  * c++: `main.cpp`
  * c#: `Program.cs`
  * rust: `main.rs`
  * python: `main.py` or `__main__.py` (in this order)

## Dependencies
If you are gonna compile C#, then you need to have `omnisharp` instaled in your system. All the other languages are shipped with their compiler already included.

## Advanced
If you want to implement custom behaviors when compiling/running, then read this section

#### Per project options
This it not necessary. But if you want, you can set per project option with `:set option=""`

* vim.g.compiler_solution_run = "" → program to run after building a solution. None if unsetted
* vim.g.compiler_output = "" → name of the resulting binary file. Default: "program"

#### Overriding actions
You can override what hapens when an action is selected on the compiler. To do so, fork this project, go to the 'compiler/languages' directory, and edit the file of the language you want. It is actually very easy.

## FAQ

* **How do build solution work?** In .NET languages you have the concept of "solution". Building a solution is just a way of saying "Build every program in this repository". To achieve this, the compiler will search in every directory of the repository for the entry point of every program and build it in parallel. It is also possible to run a program after building the solution by setting `set vim.g.compiler_solution_run="/entrypoint/file/path"`. It is recommended you manually set the option on neovim instead of in the config files, so it can be used per-project.

* **I'm coding a web, how do I run it?** Please don't try to compile/run web languages. For those cases, the solution you are looking for is most likely

  * A way to transpile: toggleterm + termux.
  * A way run the project: Just keep the website opened it your browser.
  
 > This package do not implement any of this directly due to the lack of convention in the way of transpiling/running those projects. If the situation changes and conventions are instaurated, we will implement this it the future.

* **Why is x language not implemented?** We implement all that can be implemented. But if a certain language do not have a conventional entry point, of way of compiling, there is nothing we can do.

* **I know x language that has all of that and it is not supported by the compiler, can I send a PR?** Please, be my guest.

## Language support planned for the future

* java

## 🌟 Support the project
If you want to help me, please star this repository to increase the visibility of the project.

[![Stargazers over time](https://starchart.cc/Zeioth/compiler.nvim.svg)](https://starchart.cc/Zeioth/compiler.nvim)
