#
# CMake toolchain file for Windows x86_64 compile using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
set(MK_TARGET_PROCESSOR_NAME ${CMAKE_HOST_SYSTEM_PROCESSOR})
set(MK_TARGET_TRIPLE)
set(MK_SYSROOT_PATH)

include(toolchain.cmake)
