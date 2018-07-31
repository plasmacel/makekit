#
# CMake toolchain file for native or cross compilation using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#
# MK_TARGET_TRIPLE
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

# Set target system and processor
# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_NAME.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM_PROCESSOR.html
set(CMAKE_SYSTEM_NAME ${MK_TARGET_SYSTEM})
set(CMAKE_SYSTEM_PROCESSOR ${MK_TARGET_PROCESSOR}) # arm

# https://cmake.org/cmake/help/latest/variable/CMAKE_CROSSCOMPILING.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_ROOT_PATH_MODE_PROGRAM.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_ROOT_PATH_MODE_LIBRARY.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_FIND_ROOT_PATH_MODE_INCLUDE.html
if (${CMAKE_SYSTEM_NAME} STREQUAL ${CMAKE_HOST_SYSTEM_NAME})

	set(CMAKE_CROSSCOMPILING FALSE)
	set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
	set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
	set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)

else ()

	if (NOT MK_TARGET_TRIPLE)
		message(FATAL_ERROR "No target triple specified!")
	endif ()

	# Set compiler -target flag
	# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_TARGET.html
	set(CMAKE_C_COMPILER_TARGET ${MK_TARGET_TRIPLE} CACHE STRING "" FORCE)
	set(CMAKE_CXX_COMPILER_TARGET ${MK_TARGET_TRIPLE} CACHE STRING "" FORCE)

	# Set SYSROOT path
	# https://cmake.org/cmake/help/latest/variable/CMAKE_SYSROOT.html
	# https://cmake.org/cmake/help/latest/variable/CMAKE_OSX_SYSROOT.html
	set(CMAKE_SYSROOT ${MK_SYSROOT_PATH})

	set(CMAKE_CROSSCOMPILING TRUE)
	set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
	set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
	set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

endif ()
