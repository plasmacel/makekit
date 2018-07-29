#
# CMake toolchain file for targeting the native system using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
set(MK_TARGET_PROCESSOR_NAME ${CMAKE_HOST_SYSTEM_PROCESSOR})
set(MK_TARGET_TRIPLE)
set(MK_SYSROOT_PATH)

include(toolchain.cmake)

if (NOT ${CMAKE_SYSTEM_NAME} STREQUAL ${CMAKE_HOST_SYSTEM_NAME})
	message(FATAL_ERROR "Using the native toolchain while the target platform is different from the host platform!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
	message(FATAL_ERROR "Using the x86_64 toolchain while the target processor is not x86_64!")
endif ()
