cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(MakeKit)

enable_language(CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

add_executable(mk src/mk.cpp)
add_executable(llvm-rc-rc src/llvm-rc-rc.cpp)
