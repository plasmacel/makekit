#
# CMake toolchain file for targeting Apple Darwin (macOS, iOS, tvOS, watchOS, audioOS) x86_64 using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

# Variables
set(MK_TARGET_SYSTEM_NAME "Darwin")
set(MK_TARGET_PROCESSOR_NAME "x86_64")
set(MK_TARGET_TRIPLE x86_64-apple-darwin)

set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_LINKER ld)

#set(CMAKE_C_COMPILER clang)
#set(CMAKE_CXX_COMPILER clang)
#set(CMAKE_LINKER lld)

#set(CMAKE_C_FLAGS_INIT --driver-mode=gcc ${CMAKE_C_FLAGS_INIT})
#set(CMAKE_CXX_FLAGS_INIT --driver-mode=g++ ${CMAKE_CXX_FLAGS_INIT})

#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor darwin)
#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor darwin)
#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor darwin)
#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor darwin)

# https://cmake.org/cmake/help/latest/variable/CMAKE_FRAMEWORK_PATH.html

include(toolchain.cmake)

if (NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	message(FATAL_ERROR "Using the macOS toolchain while the target platform is not macOS!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
	message(FATAL_ERROR "Using the x86_64 toolchain while the target processor is not x86_64!")
endif ()
