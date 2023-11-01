cmake_minimum_required(VERSION 3.5)

# Example of a target
project(HelloWorld)
add_executable(hello_world main.cpp)

# Example of custom target to run all tasks
add_custom_target(build_all)
add_dependencies(build_all hello_world)
