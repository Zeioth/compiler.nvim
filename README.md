# Compiler.nvim
Neovim compiler for building and running your code without having to configure anything



![screenshot_2023-06-19_13-59-07_947251291](https://github.com/Zeioth/compiler.nvim/assets/3357792/7c31d02c-2e8d-4562-bcec-323d8a468f67)

Supported languages:

* [c](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/c.lua)

Planned & coming soon:

* c++
* c#
* rust
* python
* java

## Dependencies
If you are gonna compile C#, then you need to have `omnisharp` instaled in your system. All the other languages are shipped with their compiler already included and you don't have to worry.

## How to install
lazy.nvim package manager
```lua
{ -- This plugin
  "https://github.com/Zeioth/compiler.nvim",
  dependenciens = { "stevearc/overseer.nvim" }
  event="VeryLazy",
  config = function(_, opts) require("compiler").setup(opts) end,
},
{ -- The framework we use to run tasks
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

## Available commands

| Command | Description|
|--|--|
| `:CompilerOpen` | Display the adecuated compiler for the filetype you have currently opened |
| `:CompilerToggleResults` | Open or close the compiler results. |

## Recommended mappings

```lua
-- Open compiler
vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', function() vim.cmd("CompilerOpen") end, { noremap = true, silent = true })

-- Toggle output resume
vim.api.nvim_buf_set_keymap(0, 'n', '<S-F6>',   function() vim.cmd("CompilerToggleResults" end, { noremap = true, silent = true })
```

## How to use (Basic usage)
This is what hapen when you select any of the options `build and run`, `build`, or `run` in the compiler

> compiler.nvim will look for the conventional entry point file for the current lenguage you are using. To achieve this, it searches it in your current working directory for the next files

| Language | Default entry point | Default output | 
|--|--|--|
| c | ./main.c | ./bin/program |
| c++ | ./main.cpp | ./bin/program |
| c# | ./Program.cs | ./bin/program.exe |
| rust | ./main.rs | ./bin/program |
| python | ./main.c | ./bin/program |
| java | ./main.java | ./bin/program |

This is how the compilation results look after choosig `Build & run program` in c
![screenshot_2023-06-19_13-59-37_766847673](https://github.com/Zeioth/compiler.nvim/assets/3357792/42c4ec0d-4446-4ac6-9c4a-478a32d23ca7)

## How to create a solution (Advanced)
If you want to have more control, you can create a `.solution` file in your working directory using this template 

```
[HELLO WORLD]
entry_point = "/path/to/my/entry_point_file/main.c"
output = "/path/where/the/program/will/be/written/hello_world"
parameters = ""

[SOLUTION]
executable = "/program/to/execute/after/the/solution/has/compiled/this_is_my_program"
```

Where every [entry] represents a program to compile

| option | Description |
|--|--|
| [entry] | Anything inside the brackets will be ignored. Write anything you want inside. You can use it to identify for program easily.  |
| entry_point | Path of the file containint the entry point of the program.  | 
| output | Path where the compiled program will be written. | 
| parameters | Are optional parameters to pass to the compiler. If you don't need them. You can delete this option or leave it as emtpy string if you want  |

[SOLUTION] represents the executable to run after the compilations. This section is optional and can be deleted safely.

| Option | Description |
|--|--|
| [SOLUTION] | Anything inside the brackts will be ignored. But keeping the the default name [SOLUTION] is recommended. |
| executable | Path to a program to execute after the compilation finishes. | 

Please, respect the syntax of the config file, as we intentionally do not parse errors in order to keep the compiler code simple.

## Make (Advanced)
Some times you already have a Makefile that builds the project. This option will look for a Makefile in the working directory and execute it with `make Makefile`. If your Makefile is not in the working directory, you can create a simbolic link to it (and add it to .gitignore).

## FAQ

* **How can I add a language that is not supported yet?** Fork the project, and go to the directory `/compiler/languages`. Copy `c.lua` and copy it. Rename it to any language you would like to add, for example `ruby.lua`. Now modify the file the way you want. It is important you name the file as the filetype of the language you are implementing. Then please, submit a PR to this repo so everyone can benefit from it.
* **How can I change the way the compiler works?** Same as the previous one.
* **Where are the global options?** There are not. Creating a `.solution` file of your project is the way to configure stuff. This way we can keep to code extra simple.
* **But I don't want to create a .solution file! I already have a .sln file!:** I understand your pain but .sln is a closed format of a private company.
* **I'm coding a web, how do I run it?** Please don't try to compile/run web languages. For those cases, I recommend you this strategy:
  
  * A way to transpile: toggleterm + termux.
  * A way run the project: Just keep the website opened it your browser.

    
## 🌟 Support the project
If you want to help me, please star this repository to increase the visibility of the project.

[![Stargazers over time](https://starchart.cc/Zeioth/compiler.nvim.svg)](https://starchart.cc/Zeioth/compiler.nvim)
