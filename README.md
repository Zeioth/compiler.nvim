Most people (specially beginers) are familiarized with the way visual studio IDE compiles your program without making questions. This package gives you that for all the languages that allow it.

* c
* c++
* c#
* rust
* python

Please don't try to compile/run web languages. For those cases, the solution you are looking for is most likely toggleterm + termux, which this package does not support due to the lack of convention about the way to compile/run those projects.

## Purpose
Making compiling an running the program you are writing as painless as possible.

## FAQ

**How to NeoCompiler know how to compile?** It looks for the conventional entry point file of that lenguage. To achieve this, it searches upwads in the directory tree from the file you are currently editing. It will search for the next file names.

  * c: main.c
  * c++: main.cpp
  * c#: Program.cs
  * rust: main.rs
  * python: __main__.py or main.py (in this order)

**How do build solution work?** In .NET languages you have the concept of "solution". Building a solution is just a way of saying "Build every program in this repository". To achieve this, NeoCompiler will search in every directory of the repository for the entry point of every program and build it in parallel. It is also possible to run the a program after building the solution by setting `set vim.g.compiler_solution_run="/entrypoint/path"`. It is recommended you manually set the option on neovim, so it can be used per-project.
