#
# CMake toolchain file for targeting Linux x86_64 using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME "Linux")
set(MK_TARGET_PROCESSOR_NAME "x86_64")
set(MK_TARGET_TRIPLE x86_64-pc-linux-gnu)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_LINKER lld)

#set(CMAKE_C_COMPILER clang)
#set(CMAKE_CXX_COMPILER clang)
#set(CMAKE_LINKER lld)

set(CMAKE_AR llvm-ar)
set(CMAKE_RANLIB llvm-ranlib)

set(CMAKE_C_FLAGS_INIT --driver-mode=gcc ${CMAKE_C_FLAGS_INIT})
set(CMAKE_CXX_FLAGS_INIT --driver-mode=g++ ${CMAKE_CXX_FLAGS_INIT})

set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor gnu)
set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor gnu)
set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor gnu)
set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor gnu)

include(toolchain.cmake)

if (NOT ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	message(FATAL_ERROR "Using the Linux toolchain while the target platform is not Linux!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
	message(FATAL_ERROR "Using the x86_64 toolchain while the target processor is not x86_64!")
endif ()
