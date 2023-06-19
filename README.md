Neovim compiler capable of building and running the next languages without the need of configuring anything

* [c](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/c.lua)

Planned and coming soon:

* c++
* c#
* rust
* python

## Dependencies
If you are gonna compile C#, then you need to have `omnisharp` instaled in your system. All the other languages are shipped with their compiler already included so you don't have to worry.

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

## Commands

| Command | Description|
|--|--|
| CompilerOpen | Display the adecuated compiler for the filetype you have currently opened |
| CompilerResultsToggle | Open or close the compiler results. |

## Recommended mappings

```
-- Open compiler
vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', function() vim.cmd("CompilerOpen") end, { noremap = true, silent = true })

-- Toggle output resume
vim.api.nvim_buf_set_keymap(0, 'n', '<S-F6>',   function() vim.cmd("CompilerResultsToggle" end, { noremap = true, silent = true })
```

## How to open/close
Press `F6` to open the compiler.

Press `Shift+F6` or `q` to close the results after you are done.

## How to use
This is what hapen when you use `build and run`, `build`, or `run`

> compiler.nvim will look for the conventional entry point file for the current lenguage you are using. To achieve this, it searches it in your current working directory for the next files

  * c: `main.c`
  * c++: `main.cpp`
  * c#: `Program.cs`
  * rust: `main.rs`
  * python: `main.py` or `__main__.py` (in this order)

For Make, the compiler will search for Makefile in the working directory and run it.

## How to create a solution
If you want to have more control, you can create a `.solution` file in your working directory and use this template 

```
[HELLO_WORLD]
entry_point = /path/to/my/entry_point_file/main.c
output = /path/where/the/program/will/be/written/hello_world

[SOLUTION]
executable = /program/to/execute/after/the/solution/has/compiled/this_is_my_program
```

Where:

* Every [ENTRY] represents a program to compile
* [SOLUTION] represents the executable to run after the compilations. This section is optional and can be deleted.
* Anything inside of the brackets will be ignored, it is just for you to identify your program easily.

Please, respect the syntax of the config file, as we intentionally do not parse errors in order to keep the compiler code simple.

## Make
Some times you already have a Makefile that builds the project. This option will look for a Makefile in the working directory. If your Makefile is somewhere else, just create a simbolic link to it (and add it to .gitignore).



## Advanced


#### Overriding actions


## FAQ

* **How can I add a language that is not supported yet?** Fork the project, and go to the directory `/compiler/languages`. Copy `c.lua` and copy it. Rename it to any language you would like to add, for example `ruby.lua`. Now modify the file the way you want. It is important you name the file as the filetype of the language you are implementing. Then please, submit a PR to this repo so everyone can benefit from it.
* **How can I change the way the compiler works?** Same as the previous one.
* **How do I run a solution?** In .NET languages you have the concept of "solution". Building a solution is just a way of saying "Build every program in this repository". To achieve this, the compiler will search in every directory of the repository for the entry point of every program and build it in parallel. It is also possible to run a program after building the solution by setting `set vim.g.compiler_solution_run="/entrypoint/file/path"`. It is recommended you manually set the option on neovim instead of in the config files, so it can be used per-project.

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
