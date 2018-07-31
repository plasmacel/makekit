#
# CMake toolchain file for targeting the native system using LLVM/clang
# https://clang.llvm.org/docs/CrossCompilation.html
#

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

if (NOT MK_TOOLCHAIN_PARSED)
	message(STATUS "Configuring using the LLVM native toolchain")
	set(MK_TOOLCHAIN_PARSED TRUE)
endif ()

# Set target system name and processor
set(CMAKE_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})
set(CMAKE_SYSTEM_VERSION set(CMAKE_HOST_SYSTEM_VERSION)
set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})

# Set forced compiler flags (optional)
#set(CMAKE_C_COMPILER_FORCED TRUE)
#set(CMAKE_CXX_COMPILER_FORCED TRUE)

# Set initial C/C++ compiler flags
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS_INIT.html
if (CMAKE_HOST_WIN32) # True when the target system is Windows, including Win64.

	set(CMAKE_C_COMPILER "clang-cl" CACHE FILEPATH "" FORCE)
	set(CMAKE_CXX_COMPILER "clang-cl" CACHE FILEPATH "" FORCE)
	set(CMAKE_LINKER "lld-link" CACHE FILEPATH "" FORCE)
	set(CMAKE_RC_COMPILER "llvm-rc" CACHE FILEPATH "" FORCE)
	
	#set(CMAKE_C_FLAGS_INIT --driver-mode=cl ${CMAKE_C_FLAGS_INIT})
	#set(CMAKE_CXX_FLAGS_INIT --driver-mode=cl ${CMAKE_CXX_FLAGS_INIT})

	#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor link)
	#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor link)
	#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor link)
	#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor link)

else ()

	set(CMAKE_ASM_COMPILER "llvm-as" CACHE FILEPATH "" FORCE)
	set(CMAKE_C_COMPILER "clang" CACHE FILEPATH "" FORCE)
	set(CMAKE_CXX_COMPILER "clang++" CACHE FILEPATH "" FORCE)
	set(CMAKE_LINKER "lld-link" CACHE FILEPATH "" FORCE)
	set(CMAKE_RC_COMPILER "llvm-rc" CACHE FILEPATH "" FORCE)

	#set(CMAKE_C_FLAGS_INIT --driver-mode=gcc ${CMAKE_C_FLAGS_INIT})
	#set(CMAKE_CXX_FLAGS_INIT --driver-mode=g++ ${CMAKE_CXX_FLAGS_INIT})

	if (CMAKE_HOST_APPLE)
		set(CMAKE_LINKER "ld" CACHE FILEPATH "" FORCE)
		#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor darwin)
		#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor darwin)
		#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor darwin)
		#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor darwin)
	else ()
		set(CMAKE_LINKER "lld" CACHE FILEPATH "" FORCE)
		#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor gnu)
		#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor gnu)
		#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor gnu)
		#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor gnu)
	endif()

	set(CMAKE_AR "llvm-ar" CACHE FILEPATH "" FORCE)
	set(CMAKE_RANLIB "llvm-ranlib" CACHE FILEPATH "" FORCE)

endif()

set(CMAKE_CROSSCOMPILING FALSE)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)

if (NOT ${CMAKE_SYSTEM_NAME} STREQUAL ${CMAKE_HOST_SYSTEM_NAME})
	message(FATAL_ERROR "Using the native toolchain while the target OS is different from the host OS!")
endif ()

if (NOT ${CMAKE_SYSTEM_PROCESSOR} STREQUAL ${CMAKE_HOST_SYSTEM_PROCESSOR})
	message(FATAL_ERROR "Using the native toolchain while the target processor is different from the native processor!")
endif ()
