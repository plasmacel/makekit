#
# CMake toolchain file for targeting Windows x86_64 using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

if (NOT MK_TOOLCHAIN_PARSED)
	message(STATUS "Configuring using the LLVM x86_64 Windows toolchain")
	set(MK_TOOLCHAIN_PARSED TRUE)
endif ()

# Variables
set(MK_TARGET_SYSTEM_NAME "Windows")
set(MK_TARGET_PROCESSOR_NAME "x86_64")
set(MK_TARGET_TRIPLE x86_64-pc-windows-msvc)

set(CMAKE_C_COMPILER clang-cl)
set(CMAKE_CXX_COMPILER clang-cl)
set(CMAKE_RC_COMPILER llvm-rc)
set(CMAKE_LINKER lld-link)
set(CMAKE_ASM_MASM_COMPILER ml64) # or ml
#set(CMAKE_C_COMPILER clang)
#set(CMAKE_CXX_COMPILER clang)
#set(CMAKE_RC_COMPILER llvm-rc)
#set(CMAKE_LINKER lld)

#set(CMAKE_C_FLAGS_INIT --driver-mode=cl ${CMAKE_C_FLAGS_INIT})
#set(CMAKE_CXX_FLAGS_INIT --driver-mode=cl ${CMAKE_CXX_FLAGS_INIT})

#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor link ${CMAKE_EXE_LINKER_FLAGS_INIT})
#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor link ${CMAKE_MODULE_LINKER_FLAGS_INIT})
#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor link ${CMAKE_SHARED_LINKER_FLAGS_INIT})
#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor link ${CMAKE_STATIC_LINKER_FLAGS_INIT})

include(toolchain.cmake)

if (NOT ${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	message(FATAL_ERROR "Using the Windows toolchain while the target system is not Windows!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
	message(FATAL_ERROR "Using the x86_64 toolchain while the target processor is not x86_64!")
endif ()
