cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(untitled)

#
# Variables
#

set(MAKEKIT_ASM OFF)
set(MAKEKIT_AUTODEPLOY OFF)
set(MAKEKIT_CUDA OFF)
set(MAKEKIT_OPENCL OFF)
set(MAKEKIT_OPENGL OFF)
set(MAKEKIT_OPENMP OFF) # system default or LLVM libomp
set(MAKEKIT_VULKAN OFF)
set(MAKEKIT_QT OFF) # like Core Gui OpenGL Widgets Network

set(MAKEKIT_MODULE_MODE 4)
set(MAKEKIT_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})

#
# Include MakeKit
#

include($ENV{MAKEKIT_DIR}/cmake/mk.cmake)

#
# Custom libraries
#

#target_link_libraries(${PROJECT_NAME} mylib.lib)
