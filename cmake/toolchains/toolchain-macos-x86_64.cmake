#
# CMake toolchain file for targeting Apple Darwin (macOS, iOS, tvOS, watchOS, audioOS) x86_64 using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME "Darwin")
set(MK_TARGET_PROCESSOR_NAME "x86_64")
set(MK_TARGET_TRIPLE x86_64-apple-darwin)

include(toolchain.cmake)

if (NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	message(FATAL_ERROR "Using the macOS toolchain while the target platform is not macOS!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
	message(FATAL_ERROR "Using the x86_64 toolchain while the target processor is not x86_64!")
endif ()
