project('HelloWorld', 'cpp')

# Example of a target
hello_world = executable('hello_world', 'main.cpp')

# Example of custom target to run all tasks
build_all_target = custom_target('build_all', command: 'echo', output: 'echo', input: [hello_world])
