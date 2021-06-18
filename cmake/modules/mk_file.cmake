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

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

#
# File operations
#

# mk_collect_files(<OUTPUT_LIST> <PATH> PATTERN <...> EXCLUDE <...> [ABSOLUTE | RELATIVE])
# TODO should be a function maybe
macro(mk_collect_files OUTPUT_LIST PATH)

	# Parse arguments

	set(OPTION_KEYWORDS "ABSOLUTE" "RELATIVE")
	set(SINGLE_VALUE_KEYWORDS "")
	set(MULTI_VALUE_KEYWORDS "PATTERN" "EXCLUDE")
	cmake_parse_arguments("ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

	# Set relative arguments

	if (ARGS_RELATIVE)
		set(RELATIVE_ARGS "RELATIVE ${PATH}")
	else ()
		set(RELATIVE_ARGS "")
	endif ()

	# Transform pattern

	list(TRANSFORM ARGS_PATTERN PREPEND "${PATH}/")

	#mk_message(STATUS "Collecting files: ${ARGS_PATTERN}")
	file(GLOB_RECURSE ${OUTPUT_LIST} ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${ARGS_PATTERN})
	#mk_message(STATUS "Collected files: ${${OUTPUT_LIST}}")
	
	# Excluding CMake generated files from the results just for safety
	if (ARGS_EXCLUDE)
		list(FILTER ${OUTPUT_LIST} EXCLUDE REGEX ".*CMakeFiles/.*")
		list(FILTER ${OUTPUT_LIST} EXCLUDE REGEX ${ARGS_EXCLUDE})
	endif ()

endmacro()

# mk_collect_files(<OUTPUT_LIST> PATH <...> PATTERN <...> EXCLUDE <...>)
macro(mk_collect_files_multipath OUTPUT_LIST)

	# Parse arguments

	set(OPTION_KEYWORDS "")
	set(SINGLE_VALUE_KEYWORDS "")
	set(MULTI_VALUE_KEYWORDS "PATH" "PATTERN" "EXCLUDE")
	cmake_parse_arguments("ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

	# Create GLOB expressions as combinations of GLOB_PATH/GLOB_PATTERN

	foreach (GLOB_PATH IN LISTS ARGS_PATH)
		foreach(GLOB_PATTERN IN LISTS ARGS_PATTERN)
			list(APPEND GLOB_EXPRESSIONS ${GLOB_PATH}/${GLOB_PATTERN})
		endforeach()
	endforeach ()

	# Perform GLOB

	#mk_message(STATUS "Collecting files: ${GLOB_EXPRESSIONS}")
	file(GLOB_RECURSE ${OUTPUT_LIST} ${MK_CONFIGURE_DEPENDS} ${GLOB_EXPRESSIONS})
	#mk_message(STATUS "Collected files: ${${OUTPUT_LIST}}")
	
	# Excluding CMake generated files from the results just for safety

	if (ARGS_EXCLUDE)
		list(FILTER ${OUTPUT_LIST} EXCLUDE REGEX ".*CMakeFiles/.*")
		list(FILTER ${OUTPUT_LIST} EXCLUDE REGEX ${ARGS_EXCLUDE})
	endif ()

endmacro()

# mk_collect_sources(<OUTPUT_LIST> <SOURCE_DIR>)
macro(mk_collect_sources OUTPUT_LIST SOURCE_DIR)

	#list(APPEND OUTPUT_LIST ${FILE_LIST})

	unset(${OUTPUT_LIST})

	# ASM files

	mk_collect_files(FILE_LIST ${SOURCE_DIR} PATTERN ${MK_ASM_SOURCE_SUFFIX} ABSOLUTE)
	#set(${OUTPUT_LIST} ${${OUTPUT_LIST}} FILE_LIST PARENT_SCOPE)
	list(APPEND ${OUTPUT_LIST} ${FILE_LIST})

	# C source files

	mk_collect_files(FILE_LIST ${SOURCE_DIR} PATTERN ${MK_C_SOURCE_SUFFIX} ABSOLUTE)
	#set(${OUTPUT_LIST} ${${OUTPUT_LIST}} FILE_LIST PARENT_SCOPE)
	list(APPEND ${OUTPUT_LIST} ${FILE_LIST})

	# CXX source files

	mk_collect_files(FILE_LIST ${SOURCE_DIR} PATTERN ${MK_CXX_SOURCE_PATTERN} ABSOLUTE)
	#set(${OUTPUT_LIST} ${${OUTPUT_LIST}} FILE_LIST PARENT_SCOPE)
	list(APPEND ${OUTPUT_LIST} ${FILE_LIST})

	# CXX header files

	mk_collect_files(FILE_LIST ${SOURCE_DIR} PATTERN ${MK_CXX_HEADER_PATTERN} ABSOLUTE)
	foreach (CXX_HEADER ${FILE_LIST})
		set_property(SOURCE ${CXX_HEADER} PROPERTY HEADER_FILE_ONLY ON)
	endforeach ()
	#set(${OUTPUT_LIST} ${${OUTPUT_LIST}} FILE_LIST PARENT_SCOPE)
	list(APPEND ${OUTPUT_LIST} ${FILE_LIST})

	# CXX inline files

	mk_collect_files(FILE_LIST ${SOURCE_DIR} PATTERN ${MK_CXX_INLINE_PATTERN} ABSOLUTE)
	foreach (CXX_INLINE ${FILE_LIST})
		set_property(SOURCE ${CXX_INLINE} PROPERTY HEADER_FILE_ONLY ON)
	endforeach ()
	#set(${OUTPUT_LIST} ${${OUTPUT_LIST}} FILE_LIST PARENT_SCOPE)
	list(APPEND ${OUTPUT_LIST} ${FILE_LIST})

	# CUDA source files

	mk_collect_files(FILE_LIST ${SOURCE_DIR} PATTERN ${MK_CUDA_SOURCE_PATTERN} ABSOLUTE)
	#set(${OUTPUT_LIST} ${${OUTPUT_LIST}} FILE_LIST PARENT_SCOPE)
	list(APPEND ${OUTPUT_LIST} ${FILE_LIST})

endmacro()

# mk_find_sources
# DEPRECATED
macro(mk_find_sources SOURCE_DIR)
	message(STATUS "Finding sources in ${SOURCE_DIR}")

	if (${ARGC} GREATER 1 AND ARGV1)
		set(RELATIVE_ARGS "RELATIVE ${SOURCE_DIR}")
	else ()
		unset(RELATIVE_ARGS)
	endif ()

	#file(GLOB_RECURSE C_SOURCES ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.c)
	#file(GLOB_RECURSE C_HEADERS ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.h)

	file(GLOB_RECURSE CXX_SOURCES ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.cc ${SOURCE_DIR}/*.c++ ${SOURCE_DIR}/*.cpp ${SOURCE_DIR}/*.cxx)
	file(GLOB_RECURSE CXX_HEADERS ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.h ${SOURCE_DIR}/*.hh ${SOURCE_DIR}/*.h++ ${SOURCE_DIR}/*.hpp ${SOURCE_DIR}/*.hxx)
	file(GLOB_RECURSE CXX_INLINES ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.inc ${SOURCE_DIR}/*.inl ${SOURCE_DIR}/*.ipp ${SOURCE_DIR}/*.ixx ${SOURCE_DIR}/*.tpp ${SOURCE_DIR}/*.txx)
	#file(GLOB_RECURSE CXX_OBJECTS ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${CMAKE_CXX_OUTPUT_EXTENSION})
	if (MK_OS_WINDOWS)
		file(GLOB_RECURSE CXX_OBJECTS ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.obj)
	else ()
		file(GLOB_RECURSE CXX_OBJECTS ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.o)
	endif ()

	# if ("ASM" IN_LIST ${ENABLED_LANGUAGES})
	if (MK_ASM)
		file(GLOB_RECURSE ASM_SOURCES ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.asm ${SOURCE_DIR}/*.s)
	endif ()

	# if ("CUDA" IN_LIST ${ENABLED_LANGUAGES})
	if (MK_CUDA)
		file(GLOB_RECURSE CUDA_SOURCES ${RELATIVE_ARGS} ${MK_CONFIGURE_DEPENDS} ${SOURCE_DIR}/*.cu)
	endif ()

	#
	# Set source properties
	#

	foreach (CXX_HEADER ${CXX_HEADERS})
		set_property(SOURCE ${CXX_HEADER} PROPERTY HEADER_FILE_ONLY ON)
	endforeach ()

	foreach (CXX_INLINE ${CXX_INLINES})
		set_property(SOURCE ${CXX_INLINE} PROPERTY HEADER_FILE_ONLY ON)
	endforeach ()

	#
	# Excluding CMake generated files from source for safety
	#

	list(FILTER CXX_SOURCES EXCLUDE REGEX ".*CMakeFiles/.*")
	list(FILTER CXX_HEADERS EXCLUDE REGEX ".*CMakeFiles/.*")
	list(FILTER CXX_INLINES EXCLUDE REGEX ".*CMakeFiles/.*")
	list(FILTER CXX_OBJECTS EXCLUDE REGEX ".*CMakeFiles/.*")
endmacro()

# mk_save_list(<FILENAME> <LIST> [<SEPARATOR>])
function(mk_save_list FILENAME LIST)

	if (ARGV3)
		string(REPLACE ";" ${ARGV3} LIST "${LIST}")
	endif ()
	
	file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}" "${LIST}")

endfunction()