#
#	MIT License
#
#	Copyright (c) 2018 Celestin de Villa
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#	
#	The above copyright notice and this permission notice shall be included in all
#	copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#	SOFTWARE.
#

#
# OpenMP
# https://cmake.org/cmake/help/v3.10/module/FindOpenMP.html
#

function(mk_target_link_OpenMP TARGET_NAME)

	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (${TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")
		set(LINK_SCOPE INTERFACE)
		set(COMPILE_OPTIONS_SCOPE INTERFACE)
	else ()
		unset(LINK_SCOPE)
		set(COMPILE_OPTIONS_SCOPE PRIVATE)
	endif ()

	if (TRUE) # Use LLVM libomp
		set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} "") # Append empty string to the list of library prefixes
		find_library(LIBOMP_LIB libomp PATHS $ENV{MK_LLVM_DIR}/lib REQUIRED) # add NO_DEFAULT_PATH to restrict to LLVM-installed libomp

		if (NOT LIBOMP_LIB)
			mk_message(FATAL_ERROR "OpenMP (libomp) libraries cannot be found!")
			return()
		endif ()
	
		if (MK_OS_WINDOWS)
			target_compile_options(${TARGET_NAME} ${COMPILE_OPTIONS_SCOPE} -Xclang -fopenmp)
		else ()
			target_compile_options(${TARGET_NAME} ${COMPILE_OPTIONS_SCOPE} -fopenmp=libomp)
		endif ()
		
		target_link_libraries(${TARGET_NAME} ${LINK_SCOPE} ${LIBOMP_LIB})
		mk_target_deploy_libraries(${TARGET_NAME} ${LIBOMP_LIB})
	else ()
		find_package(OpenMP REQUIRED)

		if (NOT OpenMP_FOUND)
			mk_message(FATAL_ERROR "OpenMP libraries cannot be found!")
			return()
		endif ()
		
		target_link_libraries(${TARGET_NAME} ${LINK_SCOPE} OpenMP::OpenMP_CXX)
		mk_target_deploy_libraries(${TARGET_NAME} OpenMP::OpenMP_CXX)
	endif ()

endfunction()
