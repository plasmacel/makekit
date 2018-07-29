#
# CMake toolchain file for native or cross compilation using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#
# Use it like -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake
# 
#
# MK_TARGET_TRIPLET
# The triple has the general format <arch><sub>-<vendor>-<sys>-<abi>, where:
#    arch = x86_64, i386, arm, thumb, mips, etc.
#    sub = for ex. on ARM: v5, v6m, v7a, v7m, etc.
#    vendor = pc, apple, nvidia, ibm, etc.
#    sys = none, linux, win32, darwin, cuda, etc.
#    abi = eabi, gnu, android, macho, elf, etc.
#
# http://llvm.org/doxygen/Triple_8h_source.html
# Examples:
#
# Windows
# x86_64-pc-windows-msvc
#
# macOS
# x86_64-apple-darwin
# x86_64-apple-darwin17.7.0
# x86_64-apple-macos10.13.6
#
# Linux
# x86_64-pc-linux-gnu
#

# Predefined Variables
#set(MK_TARGET_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
#set(MK_TARGET_PROCESSOR_NAME ${CMAKE_HOST_SYSTEM_PROCESSOR})
#set(MK_TARGET_TRIPLE "")
#set(MK_SYSROOT_PATH "")

# Set C/C++ compiler
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang)

# Set initial C/C++ compiler flags
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS_INIT.html
if (CMAKE_WIN32) // True when the target system is Windows, including Win64.
	set(CMAKE_C_FLAGS_INIT --driver-mode=cl ${CMAKE_C_FLAGS_INIT})
	set(CMAKE_CXX_FLAGS_INIT --driver-mode=cl ${CMAKE_CXX_FLAGS_INIT})
else ()
	set(CMAKE_C_FLAGS_INIT --driver-mode=gcc ${CMAKE_C_FLAGS_INIT})
	set(CMAKE_CXX_FLAGS_INIT --driver-mode=g++ ${CMAKE_CXX_FLAGS_INIT})
endif()

# Set target system and processor
# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_PROCESSOR.html
set(CMAKE_SYSTEM_NAME ${MK_TARGET_SYSTEM_NAME})
set(CMAKE_SYSTEM_PROCESSOR ${MK_TARGET_PROCESSOR_NAME}) # arm

# Set SYSROOT path
# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSROOT.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_OSX_SYSROOT.html
set(CMAKE_SYSROOT ${MK_SYSROOT_PATH})

# Set compiler -target flag
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_TARGET.html
if (MK_TARGET_TRIPLE)
	set(CMAKE_C_COMPILER_TARGET ${MK_TARGET_TRIPLE})
	set(CMAKE_CXX_COMPILER_TARGET ${MK_TARGET_TRIPLE})
endif ()

# https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_ROOT_PATH_MODE_PROGRAM.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_ROOT_PATH_MODE_LIBRARY.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_ROOT_PATH_MODE_INCLUDE.html
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# https://cmake.org/cmake/help/latest/variable/CMAKE_CROSSCOMPILING.html
if (${CMAKE_SYSTEM_NAME} STREQUAL ${CMAKE_HOST_SYSTEM_NAME})
	set(CMAKE_CROSSCOMPILING TRUE)
else ()
	set(CMAKE_CROSSCOMPILING FALSE)
endif ()
