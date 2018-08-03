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
	set(CMAKE_RC_COMPILER "llvm-rc-rc" CACHE FILEPATH "" FORCE)
	set(CMAKE_LINKER "lld-link" CACHE FILEPATH "" FORCE)
	
	#set(CMAKE_C_FLAGS_INIT --driver-mode=cl ${CMAKE_C_FLAGS_INIT})
	#set(CMAKE_CXX_FLAGS_INIT --driver-mode=cl ${CMAKE_CXX_FLAGS_INIT})

	#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor link)
	#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor link)
	#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor link)
	#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor link)

	set(CMAKE_CXX_FLAGS_INIT "/std:c++17" CACHE STRING "" FORCE) # Avoid a bug with clang-cl

elseif (UNIX) # True when the target system is Unix or Unix-like, including Apple Darwin and Linux.

	set(CMAKE_ASM_COMPILER "llvm-as" CACHE FILEPATH "" FORCE)
	set(CMAKE_C_COMPILER "clang" CACHE FILEPATH "" FORCE)
	set(CMAKE_CXX_COMPILER "clang++" CACHE FILEPATH "" FORCE)
	set(CMAKE_LINKER "ld.lld" CACHE FILEPATH "" FORCE)
	set(CMAKE_RC_COMPILER "llvm-rc-rc" CACHE FILEPATH "" FORCE)
	
	#set(CMAKE_C_FLAGS_INIT --driver-mode=gcc ${CMAKE_C_FLAGS_INIT})
	#set(CMAKE_CXX_FLAGS_INIT --driver-mode=g++ ${CMAKE_CXX_FLAGS_INIT})

	if (APPLE) # True when the target system is Apple Darwin, including macOS.
		#set(CMAKE_LINKER "ld.lld" CACHE FILEPATH "" FORCE)
		#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor darwin)
		#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor darwin)
		#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor darwin)
		#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor darwin)
	else ()
		#set(CMAKE_LINKER "ld.lld" CACHE FILEPATH "" FORCE)
		#set(CMAKE_EXE_LINKER_FLAGS_INIT -flavor gnu)
		#set(CMAKE_MODULE_LINKER_FLAGS_INIT -flavor gnu)
		#set(CMAKE_SHARED_LINKER_FLAGS_INIT -flavor gnu)
		#set(CMAKE_STATIC_LINKER_FLAGS_INIT -flavor gnu)
	endif()

else()
	message(FATAL_ERROR "This system is unsupported by the current toolchain!")
endif ()

# Set static libary tools
set(CMAKE_AR "llvm-ar" CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB "llvm-ranlib" CACHE FILEPATH "" FORCE)

# CMake will pass linker parameters to the compiler, so setting CMAKE_LINKER won't have any effect
# Since we want to use the default LLVM tools, this behavior is desired. Otherwise uncomment these two lines.
#set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER>  <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>" CACHE FILEPATH "" FORCE)
#set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER>  <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> <LINK_LIBRARIES>" CACHE FILEPATH "" FORCE)
