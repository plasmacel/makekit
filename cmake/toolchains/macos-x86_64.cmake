#
# CMake toolchain file for Apple Darwin x86_64 compile using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME "Darwin")
set(MK_TARGET_PROCESSOR_NAME "x86_64")
set(MK_TARGET_TRIPLE x86_64-apple-darwin)

include(toolchain.cmake)
