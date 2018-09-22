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
include_guard(GLOBAL)

set(MK_MODULE_VERSION "0.3")
set(MK_FULL_DEPLOY FALSE)

#
# Check include location
#

if (NOT ${CMAKE_CURRENT_SOURCE_DIR} STREQUAL ${CMAKE_SOURCE_DIR})
	message(FATAL_ERROR "This file should be included in the top-most level CMakeLists.txt")
endif ()

#
# Check in-source build
#

if (${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(WARNING "Configuring an in-source build. Out of source builds are highly recommended!")
endif ()

if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	message(WARNING "MakeKit - Not a valid LLVM/clang compiler!
		You are maybe using the auto native toolchain or Apple's fork of LLVM/clang shipped with Xcode instead of the genuine one.")
	#return()
endif ()

message(STATUS "MakeKit - Configuring project ${PROJECT_NAME}...")

#
# Languages and standards
#

enable_language(C)
enable_language(CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

if (MK_ASM)
	enable_language(ASM)
endif ()

if (MK_CUDA)
	enable_language(CUDA)
endif ()

#
# Output directories
#

# The CMAKE_ARCHIVE_OUTPUT_DIRECTORY variable is used to initialize the ARCHIVE_OUTPUT_DIRECTORY property on all the targets.
# ARCHIVE_OUTPUT_DIRECTORY property specifies the directory into which archive target files should be built.
# An archive output artifact of a buildsystem target may be:
# The static library file (e.g. .lib or .a) of a static library target created by the add_library() command with the STATIC option.
# On DLL platforms: the import library file (e.g. .lib) of a shared library target created by the add_library() command with the SHARED option.
# On DLL platforms: the import library file (e.g. .lib) of an executable target created by the add_executable() command when its ENABLE_EXPORTS target property is set.
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# The CMAKE_LIBRARY_OUTPUT_DIRECTORY variable is used to initialize the LIBRARY_OUTPUT_DIRECTORY property on all the targets.
# LIBRARY_OUTPUT_DIRECTORY property specifies the directory into which library target files should be built.
# A library output artifact of a buildsystem target may be:
# The loadable module file (e.g. .dll or .so) of a module library target created by the add_library() command with the MODULE option.
# On non-DLL platforms: the shared library file (e.g. .so or .dylib) of a shared shared library target created by the add_library() command with the SHARED option.
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# The CMAKE_RUNTIME_OUTPUT_DIRECTORY variable is used to initialize the RUNTIME_OUTPUT_DIRECTORY property on all the targets.
# RUNTIME_OUTPUT_DIRECTORY property specifies the directory into which runtime target files should be built.
# A runtime output artifact of a buildsystem target may be:
# The executable file (e.g. .exe) of an executable target created by the add_executable() command.
# On DLL platforms: the executable file (e.g. .dll) of a shared library target created by the add_library() command with the SHARED option.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

#
# OS Platform Detection
#

if (CMAKE_HOST_WIN32) # True if the host system is running Windows, including Windows 64-bit and MSYS, but false on Cygwin.
	message(STATUS "MakeKit - Detected OS: Windows")
	set(MK_OS_WINDOWS 1)
	set(MK_RUNTIME_LIBRARY_EXTENSION .dll)
elseif (CMAKE_HOST_UNIX) # True for UNIX and UNIX like operating systems, including APPLE operation systems and Cygwin.
	set(MK_OS_UNIX 1)
	if (CMAKE_HOST_APPLE) # True for Apple macOS operation systems.
		message(STATUS "MakeKit - Detected OS: macOS")
		set(MK_OS_MACOS 1)
		set(MK_RUNTIME_LIBRARY_EXTENSION .dylib)
	else ()
		message(STATUS "MakeKit - Detected OS: Unix/Linux")
		set(MK_OS_LINUX 1)
		set(MK_RUNTIME_LIBRARY_EXTENSION .so)
	endif ()
endif ()

#
# Include custom build types (compiler, linker and other flags)
#

include(CustomBuilds.cmake OPTIONAL)

#
# Find sources
#

if (TRUE) # MK_AUTO_REFRESH
	#cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
	set(MK_CONFIGURE_DEPENDS "CONFIGURE_DEPENDS")
else ()
	unset(MK_CONFIGURE_DEPENDS)
endif ()

#
# List of libraries with built-in support
#

set(MK_SUPPORTED_LIBRARIES Boost OpenCL OpenGL OpenMP Qt Vulkan)
set(MK_${PROJECT}_RUNTIME_LIBRARIES "")
set(MK_DEPLOY_FILES "")

#
# File extensions
#

set(MK_ASM_SOURCE_SUFFIX *.asm *.s)

set(MK_C_SOURCE_SUFFIX *.c)
set(MK_C_HEADER_SUFFIX *.h)

set(MK_CXX_SOURCE_PATTERN *.c *.cc *.c++ *.cpp *.cxx)
set(MK_CXX_HEADER_PATTERN *.h *.hh *.h++ *.hpp *.hxx)
set(MK_CXX_INLINE_PATTERN *.inc *.inl *.ipp *.ixx *.tpp *.txx)

if (MK_OS_WINDOWS)

	set(MK_CXX_RESOURCE_PATTERN *.rc) # Windows Resource (.rc)
	set(MK_CXX_OBJECT_LIBRARY_SUFFIX .obj) # Object (.obj)
	set(MK_CXX_STATIC_LIBRARY_SUFFIX .lib) # Library (.lib)
	set(MK_CXX_IMPORT_LIBRARY_SUFFIX .lib) # Library (.lib)
	set(MK_CXX_RUNTIME_LIBRARY_SUFFIX .dll) # Dynamic Link Library (.dll)

elseif (MK_OS_MACOS)

	set(MK_CXX_OBJECT_LIBRARY_SUFFIX .o) # Object (.obj)
	set(MK_CXX_STATIC_LIBRARY_SUFFIX .a) # Archive (.a)
	set(MK_CXX_IMPORT_LIBRARY_SUFFIX .dylib) # Mach-O Dynamic Library (.dylib)
	set(MK_CXX_RUNTIME_LIBRARY_SUFFIX .dylib) # Mach-O Dynamic Library (.dylib)

else ()

	set(MK_CXX_STATIC_LIBRARY_SUFFIX .a) # Archive (.a)
	set(MK_CXX_IMPORT_LIBRARY_SUFFIX .so) # Shared Object (.so)
	set(MK_CXX_RUNTIME_LIBRARY_SUFFIX .so) # Shared Object (.so)
	set(MK_CXX_OBJECT_LIBRARY_SUFFIX .o) # Object (.o)

endif ()

set(MK_CUDA_SOURCE_PATTERN *.cu)

#
# Functions and macros
#

# mk_message(MESSAGE_TYPE MESSAGE)
macro(mk_message MESSAGE_TYPE)
	message(${MESSAGE_TYPE} "MakeKit - ${ARGN}")
endmacro()

#
# Build types
#

set(MK_BUILD_TYPES NONE DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)

# mk_add_build_type(<NAME> <INHERIT> C_FLAGS <...> CXX_FLAGS <...> LINKER_FLAGS <...> EXE_LINKER_FLAGS <...> SHARED_LINKER_FLAGS <...> STATIC_LINKER_FLAGS <...> [LIBRARY_POSTFIX <POSTFIX>])
# This function must be invoked at the top level of the project and before the first target_link_libraries() command invocation.
function(mk_add_build_type NAME INHERIT)

	# Parse arguments

	set(OPTION_KEYWORDS "")
    set(SINGLE_VALUE_KEYWORDS "LIBRARY_POSTFIX")
    set(MULTI_VALUE_KEYWORDS "C_FLAGS" "CXX_FLAGS" "LINKER_FLAGS" "EXE_LINKER_FLAGS" "SHARED_LINKER_FLAGS" "STATIC_LINKER_FLAGS")
	cmake_parse_arguments(PARSE_ARGV 0 "ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

	# Check against existing build types

	string(TOUPPER ${NAME} NAME_UPPERCASE)
	string(TOUPPER ${INHERIT} INHERIT_UPPERCASE)

	if (${NAME_UPPERCASE} IN_LIST ${MK_BUILD_TYPES})
		mk_message(FATAL_ERROR "This is an already defined build type: ${NAME}")	
	else ()
		set(MK_BUILD_TYPES ${MK_BUILD_TYPES} ${NAME_UPPERCASE} PARENT_SCOPE)
	endif ()

	# Set cache variables

	set(CMAKE_C_FLAGS_${NAME_UPPERCASE} "${CMAKE_C_FLAGS_${INHERIT_UPPERCASE}} ${ARGS_C_FLAGS}"
		CACHE STRING "Flags used by the C compiler during ${NAME} builds"
		FORCE)

	set(CMAKE_CXX_FLAGS_${NAME_UPPERCASE} "${CMAKE_CXX_FLAGS_${INHERIT_UPPERCASE}} ${ARGS_CXX_FLAGS}"
		CACHE STRING "Flags used by the CXX compiler during ${NAME} builds"
		FORCE)

	set(CMAKE_EXE_LINKER_FLAGS_${NAME_UPPERCASE} "CMAKE_EXE_LINKER_FLAGS_${INHERIT_UPPERCASE} ${ARGS_LINKER_FLAGS} ${ARGS_EXE_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of executables during ${NAME} builds"
		FORCE)

	set(CMAKE_SHARED_LINKER_FLAGS_${NAME_UPPERCASE} "CMAKE_SHARED_LINKER_FLAGS_${INHERIT_UPPERCASE} ${ARGS_LINKER_FLAGS} ${ARGS_SHARED_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of shared libraries during ${NAME} builds"
		FORCE)

	set(CMAKE_STATIC_LINKER_FLAGS_${NAME_UPPERCASE} "CMAKE_STATIC_LINKER_FLAGS_${INHERIT_UPPERCASE} ${ARGS_LINKER_FLAGS} ${ARGS_STATIC_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of static libraries during ${NAME} builds"
		FORCE)

	set(CMAKE_${NAME_UPPERCASE}_POSTFIX "${ARGS_LIBRARY_POSTFIX}"
		CACHE STRING ""
		FORCE)

	# Mark variables as advanced

	mark_as_advanced(
		CMAKE_CXX_FLAGS_${NAME_UPPERCASE}
		CMAKE_C_FLAGS_${NAME_UPPERCASE}
		CMAKE_EXE_LINKER_FLAGS_${NAME_UPPERCASE}
		CMAKE_SHARED_LINKER_FLAGS_${NAME_UPPERCASE}
		CMAKE_STATIC_LINKER_FLAGS_${NAME_UPPERCASE}
		CMAKE_${NAME_UPPERCASE}_POSTFIX)

	# Update the documentation string of CMAKE_BUILD_TYPE for GUIs

	set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}"
		CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel ${NAME}"
		FORCE)

	if (CMAKE_CONFIGURATION_TYPES) # This is defined for multi-configuration generators
		set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES} ${NAME}"
			CACHE STRING "List of configuration types for multi-configuration generators"
			FORCE)
	endif ()

	# If ${NAME} is a debug configuration, then add it to the list DEBUG_CONFIGURATIONS
	# This property must be set at the top level of the project and before the first target_link_libraries() command invocation.
	# https://cmake.org/cmake/help/v3.12/prop_gbl/DEBUG_CONFIGURATIONS.html

	if (${INHERIT_UPPERCASE} STREQUAL "DEBUG")
		set(DEBUG_CONFIGURATIONS "${DEBUG_CONFIGURATIONS} ${NAME}"
			CACHE STRING "List of debug configurations"
			FORCE)
	endif()

endfunction()

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

#
# Target operations
#

# mk_add_imported_library(<LIBRARY_NAME> <LIBRARY_TYPE> <LIBRARY_INCLUDE_DIRECTORIES> [IMPORT <LIBRARY_IMPORT_FILE>] [IMPORT_<CONFIG> <LIBRARY_IMPORT_FILE>])
# where LIBRARY_TYPE can be INTERFACE, OBJECT, SHARED, STATIC
function(mk_add_imported_library LIBRARY_NAME LIBRARY_TYPE LIBRARY_INCLUDE_DIRECTORIES)

	# Parse arguments

	set(OPTION_KEYWORDS "")
    set(SINGLE_VALUE_KEYWORDS ${MK_BUILD_TYPES})
	list(TRANSFORM SINGLE_VALUE_KEYWORDS PREPEND "IMPORT_")
	list(APPEND SINGLE_VALUE_KEYWORDS "IMPORT")
    set(MULTI_VALUE_KEYWORDS "")
	cmake_parse_arguments("ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})
	
	add_library(${LIBRARY_NAME} ${LIBRARY_TYPE} IMPORTED GLOBAL)

	set_target_properties(
		${LIBRARY_NAME} PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES ${LIBRARY_INCLUDE_DIRECTORIES}
	)

	foreach(IMPORT IN ITEMS ${SINGLE_VALUE_KEYWORDS})

		if (NOT ARGS_${IMPORT})
			continue()
		endif ()

		set(LIBRARY_IMPORT ${ARGS_${IMPORT}})

		# Get extension

		get_filename_component(IMPORTED_LIBRARY_EXT ${LIBRARY_IMPORT} EXT)

		# Find platform-specific library file and set ${LIBRARY_IMPORT_FILE}

		set(LIBRARY_IMPORT_FILE "MK_${LIBRARY_NAME}_STATIC_${IMPORT}_FILE")

		if (IMPORTED_LIBRARY_EXT)
			set(${LIBRARY_IMPORT_FILE} ${LIBRARY_IMPORT} CACHE FILEPATH "")
		else ()
			get_filename_component(IMPORTED_LIBRARY_DIRECTORY ${LIBRARY_IMPORT} DIRECTORY)
			get_filename_component(IMPORTED_LIBRARY_NAME ${LIBRARY_IMPORT} NAME_WE)

			#set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} "") # Append empty string to the list of library prefixes

			# The variable name stored in LIBRARY_IMPORT_FILE is being cached
			if (${LIBRARY_TYPE} STREQUAL "OBJECT")
				find_file(${LIBRARY_IMPORT_FILE} ${IMPORTED_LIBRARY_NAME}${MK_CXX_OBJECT_LIBRARY_SUFFIX} PATHS ${IMPORTED_LIBRARY_DIRECTORY} NO_DEFAULT_PATH DOC "Path to imported library ${IMPORTED_LIBRARY_NAME}")
			else ()
				find_library(${LIBRARY_IMPORT_FILE} ${IMPORTED_LIBRARY_NAME} PATHS ${IMPORTED_LIBRARY_DIRECTORY} NO_DEFAULT_PATH DOC "Path to imported library ${IMPORTED_LIBRARY_NAME}")
			endif ()
		endif ()
	
		# Check whether the library is found

		if (${LIBRARY_IMPORT_FILE})
			mk_message(STATUS "${LIBRARY_NAME} ${IMPORT} found: ${${LIBRARY_IMPORT_FILE}}")
		else ()
			mk_message(FATAL_ERROR "${LIBRARY_NAME} ${IMPORT} cannot be found!")
			return()
		endif ()

		# Set TARGET properties

		string(REPLACE "IMPORT" "" PROPERTY_SUFFIX ${IMPORT})

		if (${LIBRARY_TYPE} STREQUAL "OBJECT") # Library is OBJECT
			set_target_properties(
				${LIBRARY_NAME} PROPERTIES
				IMPORTED_OBJECTS${PROPERTY_SUFFIX} ${${LIBRARY_IMPORT_FILE}}
				IMPORTED_IMPLIB${PROPERTY_SUFFIX} ${${LIBRARY_IMPORT_FILE}}
			)
		elseif (${LIBRARY_TYPE} STREQUAL "SHARED") # Library is SHARED
			set(LIBRARY_RUNTIME_FILE ${${LIBRARY_IMPORT_FILE}})

			if (MK_OS_WINDOWS)
				string(REGEX REPLACE "\\.[^.]*$" ${MK_CXX_RUNTIME_LIBRARY_SUFFIX} LIBRARY_RUNTIME_FILE ${${LIBRARY_IMPORT_FILE}})
			endif ()

			set_target_properties(
				${LIBRARY_NAME} PROPERTIES
				IMPORTED_LOCATION${PROPERTY_SUFFIX} ${LIBRARY_RUNTIME_FILE}
				IMPORTED_IMPLIB${PROPERTY_SUFFIX} ${${LIBRARY_IMPORT_FILE}}
			)
		else () # Library is MODULE, STATIC or UNKNOWN
			set(LIBRARY_RUNTIME_FILE ${${LIBRARY_IMPORT_FILE}})

			set_target_properties(
				${LIBRARY_NAME} PROPERTIES
				IMPORTED_LOCATION${PROPERTY_SUFFIX} ${LIBRARY_RUNTIME_FILE}
			)
		endif ()

	endforeach()
	
endfunction()

# mk_target_exclude(<TARGET_NAME> <TARGET_EXCLUDE>)
macro(mk_target_exclude TARGET_NAME TARGET_EXCLUDE)
	set_target_properties(
		${TARGET_NAME} PROPERTIES
		EXCLUDE_FROM_ALL ${TARGET_EXCLUDE}
	)
endmacro()

#
# mk_add_target(<TARGET_NAME> <TARGET_TYPE> [INCLUDE <...>] [SOURCE <...>])
function(mk_add_target TARGET_NAME TARGET_TYPE)

	# Parse arguments

	set(OPTION_KEYWORDS "WINDOWS_GUI" "MACOS_BUNDLE")
    set(SINGLE_VALUE_KEYWORDS "MACOS_BUNDLE_INFO_PLIST")
    set(MULTI_VALUE_KEYWORDS "INCLUDE" "SOURCE")
	cmake_parse_arguments("ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

	# Resolve mixed source paths/filepaths

	if (ARGS_INCLUDE)
		set(TARGET_HAS_INCLUDE_DIRS TRUE)
	else ()
		set(TARGET_HAS_INCLUDE_DIRS FALSE)
	endif ()

	foreach(TARGET_SOURCE IN ITEMS ${ARGS_SOURCE})
		if (IS_DIRECTORY ${TARGET_SOURCE}) # Find sources in the specified directory
			mk_collect_files(TARGET_SOURCES_TEMP ${TARGET_SOURCE} PATTERN ${MK_CXX_HEADER_PATTERN} ${MK_CXX_INLINE_PATTERN} ${MK_CXX_RESOURCE_PATTERN} ${MK_CXX_SOURCE_PATTERN} ABSOLUTE)
			list(APPEND TARGET_SOURCES ${TARGET_SOURCES_TEMP})
			#set(TARGET_SOURCES ${TARGET_SOURCES} ${TARGET_SOURCES_TEMP})

			if (NOT TARGET_HAS_INCLUDE_DIRS)
				list(APPEND ARGS_INCLUDE ${TARGET_SOURCE})
			endif ()
		else ()
			list(APPEND TARGET_SOURCES ${TARGET_SOURCE})
			#set(TARGET_SOURCES ${TARGET_SOURCES} ${TARGET_SOURCE})
		endif ()
	endforeach()

	#message(STATUS "INCLUDES: ${ARGS_INCLUDE}")
	#message(STATUS "SOURCES: ${TARGET_SOURCES}")

	# Check whether sources are specified

	if (NOT TARGET_SOURCES)
		mk_message(STATUS "No C/C++ sources specified.")
	endif ()

	# Add target and set its properties

	if (${TARGET_TYPE} STREQUAL "EXECUTABLE")

		add_executable(${TARGET_NAME} ${TARGET_SOURCES}) # sources can be omitted here
		target_include_directories(${TARGET_NAME} PRIVATE ${ARGS_INCLUDE})
		
		# https://cmake.org/cmake/help/latest/prop_tgt/WIN32_EXECUTABLE.html
		if (MK_OS_WINDOWS AND ARGS_WINDOWS_GUI)
			set_target_properties(
				${TARGET_NAME} PROPERTIES
				WIN32_EXECUTABLE TRUE
			)
		endif ()

		# https://cmake.org/cmake/help/latest/prop_tgt/MACOSX_BUNDLE.html
		# https://cmake.org/cmake/help/latest/prop_tgt/MACOSX_BUNDLE_INFO_PLIST.html
		if (MK_OS_MACOS AND ARGS_MACOS_BUNDLE)
			set_target_properties(
				${TARGET_NAME} PROPERTIES
				MACOSX_BUNDLE TRUE
				MACOSX_BUNDLE_INFO_PLIST "${ARGS_MACOS_BUNDLE_INFO_PLIST}"
			)
		endif ()

	else () # Library

		if (MK_OS_WINDOWS AND ARGS_WINDOWS_GUI)
			mk_message(WARNING "WINDOWS_GUI option is ignored for library targets")
		endif ()
		
		if (${TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")

			set(TARGET_INCLUDE_SCOPE "INTERFACE")
			set(TARGET_SOURCE_SCOPE "INTERFACE")

			add_library(${TARGET_NAME} INTERFACE)
			target_sources(${TARGET_NAME} INTERFACE ${TARGET_SOURCES})
			target_include_directories(${TARGET_NAME} INTERFACE ${ARGS_INCLUDE} INTERFACE ${SOURCE_DIR})

		else ()

			if (${TARGET_TYPE} STREQUAL "OBJECT_LIBRARY")
				set(TARGET_LIBRARY_TYPE "OBJECT")
			elseif (${TARGET_TYPE} STREQUAL "STATIC_LIBRARY")
				set(TARGET_LIBRARY_TYPE "STATIC")
			elseif (${TARGET_TYPE} STREQUAL "SHARED_LIBRARY")
				set(TARGET_LIBRARY_TYPE "SHARED")
			else()
				mk_message(FATAL_ERROR "Invalid target type: ${TARGET_TYPE}")
				return()
			endif ()

			add_library(${TARGET_NAME} ${TARGET_LIBRARY_TYPE} ${TARGET_SOURCES}) # sources can be omitted here, except for object libraries
			target_include_directories(${TARGET_NAME} PUBLIC ${ARGS_INCLUDE} PRIVATE ${SOURCE_DIR})

			# https://cmake.org/cmake/help/latest/prop_tgt/FRAMEWORK.html
			# https://cmake.org/cmake/help/latest/prop_tgt/MACOSX_FRAMEWORK_INFO_PLIST.html
			if (MK_OS_MACOS AND ARGS_MACOS_BUNDLE)
				set_target_properties(
					${TARGET_NAME} PROPERTIES
					FRAMEWORK TRUE
					MACOSX_FRAMEWORK_INFO_PLIST "${ARGS_MACOS_BUNDLE_INFO_PLIST}"
				)
			endif ()

		endif ()

	endif ()
	
	# Set C/C++ language standard of the target
	#set_property(TARGET ${TARGET_NAME} PROPERTY C_STANDARD 11)
	#set_property(TARGET ${TARGET_NAME} PROPERTY CXX_STANDARD 17)

	# Add pthreads on macOS and Linux
	# This is to avoid an issue when the compiler and/or the dependent libraries don't do this automatically
	# https://cmake.org/cmake/help/v3.12/module/FindThreads.html
	if (NOT MK_OS_WINDOWS)
		set(THREADS_PREFER_PTHREAD_FLAG ON)
		find_package(Threads REQUIRED)

		if (NOT Threads_FOUND)
			mk_message(FATAL_ERROR "POSIX Threads (pthreads) libraries cannot be found!")
			return()
		endif ()

		target_link_libraries(${TARGET_NAME} ${TARGET_LINK_SCOPE} Threads::Threads)
	endif ()

endfunction()

function(mk_target_deploy TARGET_NAME)

	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (NOT TARGET_TYPE STREQUAL "EXECUTABLE")
		mk_message(SEND_ERROR "mk_target_deploy(...) requires an EXECUTABLE target")
		return()
	endif ()

	# Set deploy path

	if (MK_OS_MACOS)
		get_target_property(TARGET_IS_BUNDLE ${TARGET_NAME} MACOSX_BUNDLE)
			
		if (TARGET_IS_BUNDLE)
			set(TARGET_DEPLOY_PATH $<TARGET_BUNDLE_CONTENT_DIR:${TARGET_NAME}>/Frameworks)

			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND
				${CMAKE_COMMAND} -E make_directory ${TARGET_DEPLOY_PATH})
		else ()
			set(TARGET_DEPLOY_PATH $<TARGET_FILE_DIR:${TARGET_NAME}>)
		endif ()
	else ()
		set(TARGET_DEPLOY_PATH $<TARGET_FILE_DIR:${TARGET_NAME}>)
	endif ()
	
	# Deploy runtime libraries

	mk_message(STATUS "Configuring deployment")

	get_target_property(TARGET_LINK_LIBRARIES ${TARGET_NAME} LINK_LIBRARIES)

	foreach (LIBRARY IN ITEMS ${TARGET_LINK_LIBRARIES})

		if (TARGET ${LIBRARY}) # LIBRARY is a TARGET

			get_target_property(LIBRARY_TYPE ${LIBRARY} TYPE)
			
			if (LIBRARY_TYPE STREQUAL "SHARED_LIBRARY")
				mk_message(STATUS "Deploy ${LIBRARY}")

				get_target_property(LIBRARY_IS_FRAMEWORK ${LIBRARY} FRAMEWORK)

				if (MK_OS_MACOS AND LIBRARY_IS_FRAMEWORK)
					get_target_property(LIBRARY_IS_IMPORTED ${LIBRARY} IMPORTED)

					if (LIBRARY_IS_IMPORTED) # $<TARGET_BUNDLE_DIR:${LIBRARY}> is not available for IMPORTED targets
						add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND
							${CMAKE_COMMAND} -E copy_if_different
							$<TARGET_FILE_DIR:${LIBRARY}>
							${TARGET_DEPLOY_PATH}/)
					else ()
						add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND
							${CMAKE_COMMAND} -E copy_if_different
							$<TARGET_BUNDLE_DIR:${LIBRARY}>
							${TARGET_DEPLOY_PATH}/)
					endif ()
				else ()
					add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND
						${CMAKE_COMMAND} -E copy_if_different
						$<TARGET_FILE:${LIBRARY}>
						${TARGET_DEPLOY_PATH}/)
				endif ()
			else ()
				#mk_message(STATUS "Not a shared library: ${LIBRARY}")
				continue() # Go to next iteration
			endif ()

		else () # LIBRARY is a FILEPATH

			if (IS_ABSOLUTE ${LIBRARY})
				if (MK_OS_WINDOWS)
					get_filename_component(LIBRARY_DIRECTORY ${LIBRARY} DIRECTORY)
					get_filename_component(LIBRARY_NAME_WE ${LIBRARY} NAME_WE)
					find_file(LIBRARY_RUNTIME_FILE ${LIBRARY_NAME_WE}.dll PATHS ${LIBRARY_DIRECTORY} ${LIBRARY_DIRECTORY}/../bin NO_DEFAULT_PATH REQUIRED)
				else ()
					set(LIBRARY_RUNTIME_FILE ${LIBRARY})
				endif ()
			else ()
				get_filename_component(LIBRARY_NAME_WE ${LIBRARY} NAME_WE)
				if (MK_OS_WINDOWS)
					find_file(LIBRARY_RUNTIME_FILE ${LIBRARY_NAME_WE}.dll PATHS ${CMAKE_SOURCE_DIR} NO_DEFAULT_PATH REQUIRED)
				else ()
					find_file(LIBRARY_RUNTIME_FILE ${LIBRARY} PATHS ${CMAKE_SOURCE_DIR} NO_DEFAULT_PATH REQUIRED)
				endif ()
			endif ()

			if (LIBRARY_RUNTIME_FILE)
				get_filename_component(LIBRARY_RUNTIME_FILE_NAME ${LIBRARY_RUNTIME_FILE} NAME)
				mk_message(STATUS "Deploy ${LIBRARY_RUNTIME_FILE_NAME}")
				add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LIBRARY_RUNTIME_FILE} ${TARGET_DEPLOY_PATH}/)
			else ()
				mk_message(SEND_ERROR "${LIBRARY_NAME_WE} runtime library cannot be found!")
				continue()
			endif ()

		endif ()

	endforeach ()
	
	# Deploy resources

	get_target_property(TARGET_IS_BUNDLE ${TARGET_NAME} MACOSX_BUNDLE)
	
	if (MK_OS_MACOS AND TARGET_IS_BUNDLE)
		set_target_properties(${TARGET_NAME} PROPERTIES RESOURCE "${MK_${TARGET_NAME}_DEPLOY_RESOURCES}")
	else ()
		foreach (RESOURCE_FILE IN LISTS MK_${TARGET_NAME}_DEPLOY_RESOURCES)
			get_filename_component(RESOURCE_FILE_NAME ${RESOURCE_FILE} NAME)
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different ${RESOURCE_FILE} ${TARGET_DEPLOY_PATH}/)
		endforeach ()
	endif ()
	
	# Deploy Qt

	mk_target_deploy_Qt(${TARGET_NAME})

endfunction()

# mk_target_deploy_libraries(<TARGET_NAME> [<...>])
# This macro appends the runtime library (.dll; .dylib; .so) of shared libraries to MK_RUNTIME_LIBRARIES
# It does nothing for non-shared libraries
macro(mk_target_deploy_libraries TARGET_NAME)

	#set(MK_${TARGET_NAME}_DEPLOY_LIBRARIES ${MK_${TARGET_NAME}_DEPLOY_LIBRARIES} ${ARGN} CACHE INTERNAL "")

endmacro()

# mk_target_deploy_resources(<TARGET_NAME> [<...>])
# This macro adds FILES to the list of deploy resources
macro(mk_target_deploy_resources TARGET_NAME)

	#set(MK_${TARGET_NAME}_DEPLOY_FILES ${MK_DEPLOY_FILES} ${ARGN})
	#list(APPEND MK_${TARGET_NAME}_DEPLOY_FILES ${ARGN})
	set(MK_${TARGET_NAME}_DEPLOY_RESOURCES ${MK_${TARGET_NAME}_DEPLOY_RESOURCES} ${ARGN} CACHE INTERNAL "")

endmacro()

# mk_target_link_libraries(<TARGET_NAME> [<...>])
# This macro performs target_link_libraries(${PROJECT} ${LIBRARIES}) and mk_target_deploy_libraries(${LIBRARIES})
# appends the runtime library (.dll; .dylib; .so) of shared libraries to MK_RUNTIME_LIBRARIES
# EXPERIMENTAL
macro(mk_target_link_libraries TARGET_NAME)
	
	target_link_libraries(${TARGET_NAME} ${ARGN})
	mk_target_deploy_libraries(${TARGET_NAME} ${ARGN})

endmacro()

# mk_group_sources(<SOURCE_DIR>)
# Macro to preserve source files hierarchy in the IDE
# http://www.rtrclass.type.pl/2018-05-29-how-to-setup-opengl-project-with-cmake/
macro(mk_group_sources SOURCE_DIR)

    file(GLOB CHILDREN RELATIVE ${PROJECT_SOURCE_DIR}/${SOURCE_DIR} ${MK_CONFIGURE_DEPENDS} ${PROJECT_SOURCE_DIR}/${SOURCE_DIR}/*)

    foreach (CHILD ${CHILDREN})
        if (IS_DIRECTORY ${PROJECT_SOURCE_DIR}/${SOURCE_DIR}/${CHILD})
            mk_group_sources(${SOURCE_DIR}/${CHILD})
        else ()
            string(REPLACE "/" "\\" GROUP_NAME ${SOURCE_DIR})
            string(REPLACE "src" "Sources" GROUP_NAME ${GROUP_NAME})
            source_group(${GROUP_NAME} FILES ${PROJECT_SOURCE_DIR}/${SOURCE_DIR}/${CHILD})
        endif ()
    endforeach ()

endmacro()

#
# Create source groups for IDE project generators
#

if (CXX_SOURCES)
	mk_group_sources(${PROJECT_SOURCE_DIR})
endif ()

#
# Set linker language for cases when it cannot be determined
# (for example when the source consists precompiled object files only)
#

#get_target_property(MK_LINKER_LANGUAGE ${PROJECT_NAME} LINKER_LANGUAGE)
#message(${MK_LINKER_LANGUAGE})
#if (${MK_LINKER_LANGUAGE} STREQUAL "NOTFOUND")
#    set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
#endif()
#set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY LINKER_LANGUAGE CXX)

include($ENV{MK_DIR}/cmake/libraries/OpenCL.cmake)
include($ENV{MK_DIR}/cmake/libraries/OpenGL.cmake)
include($ENV{MK_DIR}/cmake/libraries/OpenMP.cmake)
include($ENV{MK_DIR}/cmake/libraries/Qt.cmake)
include($ENV{MK_DIR}/cmake/libraries/Vulkan.cmake)
