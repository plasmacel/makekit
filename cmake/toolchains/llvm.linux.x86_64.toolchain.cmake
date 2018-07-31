#
# CMake toolchain file for targeting Linux x86_64 using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

if (NOT MK_TOOLCHAIN_PARSED)
	message(STATUS "Configuring using the LLVM x86_64 Linux toolchain")
	set(MK_TOOLCHAIN_PARSED TRUE)
endif ()

# MK Settings
set(MK_SYSROOT_PATH "")
set(MK_TARGET_SYSTEM "Linux")
set(MK_TARGET_PROCESSOR "x86_64")
set(MK_TARGET_TRIPLE "x86_64-pc-linux-gnu")

include($ENV{MK_DIR}/cmake/toolchains/llvm.toolchain.cmake)
include($ENV{MK_DIR}/cmake/toolchains/cross.settings.cmake)

if (NOT ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	message(FATAL_ERROR "Using the Linux toolchain while the target platform is not Linux!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
	message(FATAL_ERROR "Using the x86_64 toolchain while the target processor is not x86_64!")
endif ()
