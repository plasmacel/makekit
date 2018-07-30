#
# CMake toolchain file for targeting Windows x86_64 using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME "Windows")
set(MK_TARGET_PROCESSOR_NAME "x86_64")
set(MK_TARGET_TRIPLE x86_64-pc-windows-msvc)

include(toolchain.cmake)

if (NOT ${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	message(FATAL_ERROR "Using the Windows toolchain while the target system is not Windows!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
	message(FATAL_ERROR "Using the x86_64 toolchain while the target processor is not x86_64!")
endif ()
