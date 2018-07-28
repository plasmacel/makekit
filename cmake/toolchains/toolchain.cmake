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

# Variables
#set(MK_TARGET_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
#set(MK_TARGET_PROCESSOR_NAME ${CMAKE_HOST_SYSTEM_PROCESSOR})
#set(MK_TARGET_TRIPLE "")
#set(MK_SYSROOT_PATH "")

# Set target system and processor
set(CMAKE_SYSTEM_NAME ${MK_TARGET_SYSTEM_NAME})
set(CMAKE_SYSTEM_PROCESSOR ${MK_TARGET_PROCESSOR_NAME}) # arm

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

# Set SYSROOT path
# https://cmake.org/cmake/help/v3.12/variable/CMAKE_SYSROOT.html
set(CMAKE_SYSROOT ${MK_SYSROOT_PATH})

# Set compiler -target flag
if (MK_TARGET_TRIPLE)
	set(CMAKE_C_COMPILER_TARGET ${MK_TARGET_TRIPLE})
	set(CMAKE_CXX_COMPILER_TARGET ${MK_TARGET_TRIPLE})
endif ()

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_CROSS_COMPILING TRUE)
