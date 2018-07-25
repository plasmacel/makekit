cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(mk)

enable_language(CXX)
set(CMAKE_CXX_STANDARD 17)

add_executable(mk mk.cpp)
