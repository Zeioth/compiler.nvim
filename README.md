# Compiler.nvim
Neovim compiler for building and running your code without having to configure anything.

![screenshot_2023-06-19_13-59-07_947251291](https://github.com/Zeioth/compiler.nvim/assets/3357792/7c31d02c-2e8d-4562-bcec-323d8a468f67)

<div align="center">
  <a href="https://discord.gg/ymcMaSnq7d" rel="nofollow">
      <img src="https://img.shields.io/discord/1121138836525813760?color=azure&labelColor=6DC2A4&logo=discord&logoColor=black&label=Join the discord server&style=for-the-badge" data-canonical-src="https://img.shields.io/discord/1121138836525813760">
    </a>
</div>

## Table of contents

- [Supported languages](#supported-languages)
- [Required system dependencies](#required-system-dependencies)
- [How to install](#how-to-install)
- [Available commands](#available-commands)
- [Basic usage](#how-to-use-basic-usage)
- [How to create a solution (advanced)](#how-to-create-a-solution-advanced)
- [Make (advanced)](#make-advanced)
- [Quick start](#quick-start)
- [FAQ](#faq)

## Supported languages

* [c](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/c.lua)
* [c++](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/cpp.lua)
* [c#](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/cs.lua)
* [java](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/java.lua)
* [rust](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/rust.lua)
* [go](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/go.lua)
* [asm x86-64](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/asm.lua)
* [python](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/python.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/python-compiler))
* [ruby](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/ruby.lua)
* [lua](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/lua.lua)
* [perl](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/perl.lua)
* [shell](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/shell.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/shell-interpreter))
* [make](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/make.lua)


### Planned & coming soon:
Pull requests are welcome. See [FAQ](#faq).

* objetive C
* swift
* kotlin
* javascript
* typescript
* scala
* R
* elixir
* visual basic
* F
* delphy
* pascal
* cobol

## Required system dependencies
Some languages require you manually install their compilers in your machine, so compiler.nvim is able to call them. [Please check here](https://github.com/Zeioth/Compiler.nvim/wiki/how-to-install-the-required-dependencies), as the packages will be different depending your operative system.

## How to install
lazy.nvim package manager
```lua
{ -- This plugin
  "Zeioth/compiler.nvim",
  cmd = {"CompilerOpen", "CompilerToggleResults"},
  dependencies = { "stevearc/overseer.nvim" },
  config = function(_, opts) require("compiler").setup(opts) end,
},
{ -- The framework we use to run tasks
  "stevearc/overseer.nvim",
  commit = "3047ede61cc1308069ad1184c0d447ebee92d749", -- Recommended to to avoid breaking changes
  cmd = {"CompilerOpen", "CompilerToggleResults"},
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
      },
    },
  },
},
```

### Recommended mappings

```lua
-- Open compiler
vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })

-- Toggle compiler results
vim.api.nvim_buf_set_keymap(0, 'n', '<S-F6>', "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })
```

## Available commands

| Command | Description|
|--|--|
| `:CompilerOpen` | Shows the adecuated compiler for your buffer's filetype. |
| `:CompilerToggleResults` | Open or close the compiler results. |
| `:CompilerRedo` | Redo the last selected option. |


## How to use (Basic usage)
This is what hapen when you select `build & run`, `build`, or `run` in the compiler:

> compiler.nvim will look for the conventional entry point file for the current lenguage you are using. To achieve this, it searches in your current working directory for the next files

| Language | Default entry point | Default output |
|--|--|--|
| c | ./main.c | ./bin/program |
| c++ | ./main.cpp | ./bin/program |
| c# | ./Program.cs | ./bin/Program.exe |
| java | ./Main.java | ./bin/Main.class |
| rust | ./main.rs | ./bin/program |
| go | ./main.go | ./bin/program |
| asm x86-64 | ./main.asm | ./bin/program |
| python | ./main.py | ./bin/program |
| ruby | ./main.rb |  |
| lua | ./main.lua |  |
| perl | ./main.pl |  |
| shell | ./main.sh |  |
| make | ./Makefile | |

This is how the compilation results look after selecting `Build & run program` in c
![screenshot_2023-06-19_13-59-37_766847673](https://github.com/Zeioth/compiler.nvim/assets/3357792/42c4ec0d-4446-4ac6-9c4a-478a32d23ca7)
[For more info see wiki - when to use every option](https://github.com/Zeioth/compiler.nvim/wiki/When-to-use-every-option)

## How to create a solution (Advanced)
If you want to have more control, you can create a `.solution` file in your working directory by using this template:

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
| [entry] | Anything inside the brackets will be ignored. Write anything you want to easily identify your program.  |
| entry_point | Path of the file containing the entry point of the program.  | 
| output | Path where the compiled program will be written. | 
| parameters | Are optional parameters to pass to the compiler. If you don't need them you can delete this option or leave it as empty string if you want. | 

[SOLUTION] represents the executable to run after all programs in the solution have compiled. This section is optional and can be deleted safely.

| Option | Description |
|--|--|
| [SOLUTION] | Anything inside the brackets will be ignored. But keeping the the default name [SOLUTION] is recommended. |
| executable | Path to a program to execute after the compilation finishes. | 

Please, respect the syntax of the `.solution` file, as we intentionally do not parse errors in order to keep the compiler code simple. [For more examples see wiki](https://github.com/Zeioth/Compiler.nvim/wiki/solution-examples).

## Make (Advanced)
This option look for a Makefile in the working directory and execute it with `make Makefile`. [For more examples see wiki](https://github.com/Zeioth/Compiler.nvim/wiki/Makefile-examples).

## Quick start
Create `./c_example/main.c` and paste this code. Then do `:cd ./c_example/` to change the working directory to the project.

```c
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
```

All you have to do now is to open the compiler and select `Build and run`. You will see the results.

![screenshot_2023-07-25_23-56-57_069109256](https://github.com/Zeioth/compiler.nvim/assets/3357792/fd102350-ca44-4501-9cb0-db2ea0093264)

## FAQ
* **I don't have time to read:** If you prefer you can try [NormalNvim](https://github.com/NormalNvim/NormalNvim) which comes with the compiler pre-installed. Just open some code and hit F6!
* **How can I add a language that is not supported yet?** Fork the project, and go to the directory `/compiler/languages`. Copy `c.lua` and rename it to any language you would like to add, for example `ruby.lua`. Now modify the file the way you want. It is important you name the file as the filetype of the language you are implementing. Then please, submit a PR to this repo so everyone can benefit from it.
* **How can I change the way the compiler works?** Same as the previous one.
* **Is this plugin just a compiler, or can I run scripts too?** Yes you can. But if your script receive parameters, we recommend you to use the terminal instead, because creating a `.solution` file just to be able to pass parameters to your simple shell script is probably a overkill, and not the right tool.
* **Is this plugin also a building system manager?** No, it is not. For convenience, we provide the option `Run Makefile`, which should cover some cases of use. But if your workflow relies heavily on building systems, please consider installing an specific neovim plugin for this purpuse. [See wiki](https://github.com/Zeioth/Compiler.nvim/wiki/Makefile-examples#building-systems-support).
* **I'm a windows user, do I need to do something special?** In theory no. Check the [dependencies section of this README.md](https://github.com/Zeioth/Compiler.nvim/wiki/how-to-install-the-required-dependencies) and make sure you have them. If for some wild reason a required dependency don't exist on windows, or you don't know how to get it, the easy way is to enable the Windows Linux Subsystem and run neovim from there. Then you can just `sudo apt install some_package` for anything you may need.
* **Where are the global options?** There are not. Creating a `.solution` file of your project is the way to configure stuff. This way we can keep the code extra simple.
*  **How can I disable notifications when compiling?** Check [here](https://github.com/stevearc/overseer.nvim/issues/158#issuecomment-1631542247).
* **I'm coding a web, how do I run it?** Please don't try to compile/run web languages. I recommend you this strategy instead:
  
  * A way to transpile: toggleterm + tmux.
  * A way run the project: Just keep the website opened in your browser.
    
## 🌟 Support the project
If you want to help me, please star this repository to increase the visibility of the project.

[![Stargazers over time](https://starchart.cc/Zeioth/Compiler.nvim.svg)](https://starchart.cc/Zeioth/Compiler.nvim)


## Thanks to all contributors

<a href="https://github.com/zeioth/compiler.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=zeioth/compiler.nvim" />
</a>
