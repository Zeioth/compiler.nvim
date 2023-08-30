# Compiler.nvim
Neovim compiler for building and running your code without having to configure anything.

![screenshot_2023-06-19_13-59-07_947251291](https://github.com/Zeioth/compiler.nvim/assets/3357792/7c31d02c-2e8d-4562-bcec-323d8a468f67)

<div align="center">
  <a href="https://discord.gg/ymcMaSnq7d" rel="nofollow">
      <img src="https://img.shields.io/discord/1121138836525813760?color=azure&labelColor=6DC2A4&logo=discord&logoColor=black&label=Join the discord server&style=for-the-badge" data-canonical-src="https://img.shields.io/discord/1121138836525813760">
    </a>
</div>

## Table of contents

- [Why](#why)
- [Supported languages](#supported-languages)
- [Required system dependencies](#required-system-dependencies)
- [How to install](#how-to-install)
- [Commands](#commands)
- [Basic usage](#how-to-use-basic-usage)
- [Creating a solution (optional)](#creating-a-solution-optional)
- [Make](#make-optional)
- [Quick start](#quick-start)
- [FAQ](#faq)

## Why
Those familiar with Visual Studio IDE will remember how convenient it was to just press a button and having your program compiled and running. I wanted to bring that same user experience to Neovim.

## Supported languages

* [c](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/c.lua)
* [c++](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/cpp.lua)
* [c#](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/cs.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/cs-compiler))
* [java](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/java.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/java-compiler))
* [kotlin](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/kotlin.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/java-compiler))
* [rust](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/rust.lua)
* [go](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/go.lua)
* [zig](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/zig.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/zig-compiler))
* [asm x86-64](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/asm.lua)
* [visual Basic dotnet](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/vb.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/visual-basic-dotnet-compiler))
* [f#](https://github.com/Zeioth/compiler.nvim/blob/main/lua/compiler/languages/fsharp.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/fsharp-compiler))
* [r](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/r.lua)
* [python](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/python.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/python-compiler))
* [ruby](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/ruby.lua)
* [lua](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/lua.lua)
* [perl](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/perl.lua)
* [dart](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/dart.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/dart-compiler))
* [flutter](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/dart.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/dart-compiler))
* javascript → WIP
* [typescript](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/typescript.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/typescript-transpiler))
* [shell](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/shell.lua) ([more info](https://github.com/Zeioth/compiler.nvim/wiki/shell-interpreter))
* [make](https://github.com/Zeioth/Compiler.nvim/blob/main/lua/compiler/languages/make.lua)
  
## Required system dependencies
Some languages require you manually install their compilers in your machine, so compiler.nvim is able to call them. [Please check here](https://github.com/Zeioth/Compiler.nvim/wiki/how-to-install-the-required-dependencies), as the packages will be different depending your operative system.

## How to install
lazy.nvim package manager
```lua
{ -- This plugin
  "Zeioth/compiler.nvim",
  cmd = {"CompilerOpen", "CompilerToggleResults", "CompilerRedo"},
  dependencies = { "stevearc/overseer.nvim" },
  opts = {},
},
{ -- The task runner we use
  "stevearc/overseer.nvim",
  commit = "3047ede61cc1308069ad1184c0d447ebee92d749",
  cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
  opts = {
    task_list = {
      direction = "bottom",
      min_height = 25,
      max_height = 25,
      default_detail = 1,
      bindings = { ["q"] = function() vim.cmd("OverseerClose") end },
    },
  },
},
```

### Recommended mappings

```lua
-- Open compiler
vim.api.nvim_buf_set_keymap(0, 'n', '<F6>', "<cmd>CompilerOpen<cr>", { noremap = true, silent = true })

-- Redo last selected option
vim.api.nvim_buf_set_keymap(0, 'n', '<S-F6>', function()
  vim.cmd("CompilerStop") -- (Optional, to dispose all tasks before redo)
  vim.cmd("CompilerRedo")
end, { noremap = true, silent = true })

-- Toggle compiler results
vim.api.nvim_buf_set_keymap(0, 'n', '<S-F7>', "<cmd>CompilerToggleResults<cr>", { noremap = true, silent = true })
```

## Commands

| Command | Description|
|--|--|
| `:CompilerOpen` | Shows the adecuated compiler for your buffer's filetype. |
| `:CompilerToggleResults` | Open or close the compiler results. |
| `:CompilerRedo` | Redo the last selected option. |
| `:CompilerStop` | Dispose all tasks. |


## How to use (Basic usage)
This is what hapen when you select `build & run`, `build`, or `run` in the compiler:

> compiler.nvim will look for the conventional entry point file for the current language you are using. To achieve this, it searches in your current working directory for the next files

| Language | Default entry point | Default output |
|--|--|--|
| c | ./main.c | ./bin/program |
| c++ | ./main.cpp | ./bin/program |
| c# | ./Program.cs | ./bin/Program.exe |
| java | ./Main.java | ./bin/Main.class |
| kotlin | ./Main.kt | ./bin/MainKt.class |
| rust | ./main.rs | ./bin/program |
| zig | ./build.zig | ./zig-out/bin/build |
| go | ./main.go | ./bin/program |
| asm x86-64 | ./main.asm | ./bin/program |
| visual basic .net  | [see here](https://github.com/Zeioth/compiler.nvim/wiki/visual-basic-dotnet-compiler) | |
| f# | [see here](https://github.com/Zeioth/compiler.nvim/wiki/fsharp-compiler) |  |
| r | ./main.r |  |
| python | ./main.py | ./bin/program |
| ruby | ./main.rb |  |
| lua | ./main.lua |  |
| perl | ./main.pl |  |
| dart | ./lib/main.dart | ./bin/main |
| flutter | [see here](https://github.com/Zeioth/compiler.nvim/wiki/dart-compiler) | |
| typescript | ./src/index.ts |  |
| javascript | ./src/index.js |  |
| shell | ./main.sh |  |
| make | ./Makefile | |

This is how the compilation results look after selecting `Build & run program` in c
![screenshot_2023-06-19_13-59-37_766847673](https://github.com/Zeioth/compiler.nvim/assets/3357792/42c4ec0d-4446-4ac6-9c4a-478a32d23ca7)
[For more info see wiki - when to use every option](https://github.com/Zeioth/compiler.nvim/wiki/When-to-use-every-option)

## Creating a solution (optional)
If you want to have more control, you can create a `.solution.toml` file in your working directory by using this template where every [entry] represents a program to compile

```toml
[HelloWorld]
entry_point = "/path/to/my/entry_point_file/main.c"
output = "/path/where/the/program/will/be/written/hello_world"
arguments = ""

[SOLUTION]
executable = "/program/to/execute/after/the/solution/has/compiled/my_program"
```

[For more examples see wiki](https://github.com/Zeioth/Compiler.nvim/wiki/solution-examples).

## Make (optional)
This option will look for a `Makefile` in the working directory and execute it with `make Makefile`. [For more examples see wiki](https://github.com/Zeioth/Compiler.nvim/wiki/Makefile-examples).

## Quick start
Create `./c-example/main.c` and paste this code. Then do `:cd ./c-example/` to change the working directory to the project.

```c
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
```

Open the compiler and select `Build and run`. You will see the compilation results.

![screenshot_2023-07-25_23-56-57_069109256](https://github.com/Zeioth/compiler.nvim/assets/3357792/fd102350-ca44-4501-9cb0-db2ea0093264)

## FAQ
* **I get errors when compiling:** You have to  `:cd /your/project/root_dir` before calling [Compiler.nvim](https://starchart.cc/Zeioth/Compiler.nvim).
* **I don't have time to read:** If you prefer you can try [NormalNvim](https://github.com/NormalNvim/NormalNvim) which comes with the compiler pre-installed. Just open some code and hit F6!
* **How can I add a language that is not supported yet?** Fork the project, and go to the directory `/compiler/languages`. Copy `c.lua` and rename it to any language you would like to add, for example `ruby.lua`. Now modify the file the way you want. It is important you name the file as the filetype of the language you are implementing. Then please, submit a PR to this repo so everyone can benefit from it.
* **How can I change the way the compiler works?** Same as the previous one.
* **Is this plugin just a compiler, or can I run scripts too?** Yes you can. But if your script receive arguments, we recommend you to use the terminal instead, because creating a `.solution.toml` file just to be able to pass arguments to your simple shell script is probably a overkill, and not the right tool.
* **Is this plugin also a building system manager?** No, it is not. For convenience, we provide the option `Run Makefile`, which should cover some cases of use. But if your workflow relies heavily on building systems, please consider installing an specific neovim plugin for this purpose. [See wiki](https://github.com/Zeioth/Compiler.nvim/wiki/Makefile-examples#building-systems-support).
* **I'm a windows user, do I need to do something special?** You have to [enable WLS](https://www.youtube.com/watch?v=fFbLUEQsRhM), and run nvim inside. Otherwise it would be impossible for you to install the [required dependencies](https://github.com/Zeioth/Compiler.nvim/wiki/how-to-install-the-required-dependencies).
* **Where are the global options?** There are not. Creating a `.solution.toml` file of your project is the way to configure stuff. This way we can keep the code extra simple.
*  **How can I disable notifications when compiling?** Check [here](https://github.com/stevearc/overseer.nvim/issues/158#issuecomment-1631542247).
* **I'm coding a web, how do I run it?** Please don't try to compile/run web languages. I recommend you this strategy instead:
  
  * A way to transpile: toggleterm + tmux.
  * A way run the project: Just keep the website opened in your browser.
* **How can I auto `:cd` my projects?** Use [this fork](https://github.com/Zeioth/project.nvim) of the plugin `project.nvim`.

### How can I compile videogames?
The workflow of game development is essencially very different from just compiling and running a program. It involve loading editing and running scenes. While there is no way for us to support it directly, here I offer you some tricks:

#### Godot engine
To `Build and run a godot scene`, use the command `godot /my/scene.tscn` on the terminal. This works really well: It's fast and simple.

#### Unity
The recommended way is to have 2 monitors, one with nvim and your code, and another one with your unity scenes to run the game. Unity has [some terminal commands](https://docs.unity3d.com/Manual/CommandLineArguments.html), but working with them is quite a painful experience.

## 🌟 Support the project
If you want to help me, please star this repository to increase the visibility of the project.

[![Stargazers over time](https://starchart.cc/Zeioth/Compiler.nvim.svg)](https://starchart.cc/Zeioth/Compiler.nvim)


## Thanks to all contributors

<a href="https://github.com/zeioth/compiler.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=zeioth/compiler.nvim" />
</a>

## Roadmap
* Better windows compatibility when not using WLS: The commands `rm -rf` and `mkdir -p` only exist on unix. To support Windows without WLS we should run the equivalent powershell command when Windows is detected.
* Aditionally, we will also have to compile for `asm` win64 architecture, if the detected OS is windows.
* Aditionally, we will also have to add an option to compile for `Build for windows (flutter)`.
