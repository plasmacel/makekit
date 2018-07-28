#
# CMake toolchain file for Windows x86_64 compile using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME "Windows")
set(MK_TARGET_PROCESSOR_NAME "x86_64")
set(MK_TARGET_TRIPLE x86_64-pc-windows-msvc)

include(toolchain.cmake)
