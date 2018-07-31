#
# CMake inline file to set the LLVM/clang toolchain
#

# Related documentation
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS_INIT.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_LINKER.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_AR.html
# https://cmake.org/cmake/help/latest/variable/CMAKE_RANLIB.html

if (WIN32) # True when the target system is Windows, including Win64.

	set(CMAKE_ASM_COMPILER "llvm-as" CACHE FILEPATH "" FORCE)
	set(CMAKE_C_COMPILER "clang-cl" CACHE FILEPATH "" FORCE)
	set(CMAKE_CXX_COMPILER "clang-cl" CACHE FILEPATH "" FORCE)
	set(CMAKE_RC_COMPILER "llvm-rc" CACHE FILEPATH "" FORCE)
	set(CMAKE_LINKER "lld-link" CACHE FILEPATH "" FORCE)
	
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
	set(CMAKE_LINKER "ld.lld" CACHE FILEPATH "" FORCE)
	set(CMAKE_RC_COMPILER "llvm-rc" CACHE FILEPATH "" FORCE)

	#set(CMAKE_C_FLAGS_INIT --driver-mode=gcc ${CMAKE_C_FLAGS_INIT})
	#set(CMAKE_CXX_FLAGS_INIT --driver-mode=g++ ${CMAKE_CXX_FLAGS_INIT})

	if (APPLE) # True when the target system is Apple Darwin, including macOS.
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

endif()

set(CMAKE_AR "llvm-ar" CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB "llvm-ranlib" CACHE FILEPATH "" FORCE)
