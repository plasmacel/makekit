#
# CMake toolchain file for targeting the native system using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

if (NOT MK_TOOLCHAIN_PARSED)
	message(STATUS "Configuring using the LLVM native toolchain")
	set(MK_TOOLCHAIN_PARSED TRUE)
endif ()

# Set target system name and processor
set(CMAKE_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
set(CMAKE_SYSTEM_VERSION ${CMAKE_HOST_SYSTEM_VERSION})
set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})

# Set forced compiler flags (optional)
#set(CMAKE_C_COMPILER_FORCED TRUE)
#set(CMAKE_CXX_COMPILER_FORCED TRUE)

# Include LLVM toolchain
include($ENV{MK_DIR}/cmake/toolchains/llvm.toolchain.cmake)

set(CMAKE_CROSSCOMPILING FALSE)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)

if (NOT ${CMAKE_SYSTEM_NAME} STREQUAL ${CMAKE_HOST_SYSTEM_NAME})
	message(FATAL_ERROR "Using the native toolchain while the target OS is different from the host OS!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
	message(FATAL_ERROR "Using the native toolchain while the target processor is different from the native processor!")
endif ()
