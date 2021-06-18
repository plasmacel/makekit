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

include($ENV{MK_DIR}/cmake/modules/mk_defs.cmake)
include($ENV{MK_DIR}/cmake/modules/mk_config.cmake)
include($ENV{MK_DIR}/cmake/modules/mk_file.cmake)

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

#
# Target operations
#

# mk_add_imported_library(<LIBRARY_NAME> <LIBRARY_TYPE> <LIBRARY_INCLUDE_DIRECTORIES> [IMPORT <LIBRARY_IMPORT_FILE>] [IMPORT_<CONFIG> <LIBRARY_IMPORT_FILE>])
# where LIBRARY_TYPE can be INTERFACE, OBJECT, SHARED, STATIC
function(mk_add_imported_library LIBRARY_NAME LIBRARY_TYPE LIBRARY_INCLUDE_DIRECTORIES)

	# Parse arguments

	set(OPTION_KEYWORDS "")
	set(SINGLE_VALUE_KEYWORDS ${MK_CONFIGS})
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
				find_file(${LIBRARY_IMPORT_FILE} ${IMPORTED_LIBRARY_NAME}${CMAKE_OBJECT_LIBRARY_SUFFIX} PATHS ${IMPORTED_LIBRARY_DIRECTORY} NO_DEFAULT_PATH DOC "Path to imported library ${IMPORTED_LIBRARY_NAME}")
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
				string(REGEX REPLACE "\\.[^.]*$" ${CMAKE_SHARED_LIBRARY_SUFFIX} LIBRARY_RUNTIME_FILE ${${LIBRARY_IMPORT_FILE}})
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

	if (${TARGET_TYPE} STREQUAL "EXECUTABLE") # Executable

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

# mk_target_deploy(<TARGET_NAME> [PLUGINS <...>] [SEARCH <...>])
function(mk_target_deploy TARGET_NAME)

    get_target_property(TARGET_IS_MACOS_BUNDLE ${TARGET_NAME} MACOSX_BUNDLE)

#    if (TARGET_IS_MACOS_BUNDLE)
#        install(TARGETS ${TARGET_NAME} BUNDLE DESTINATION ${CMAKE_INSTALL_PREFIX})
#    else ()
#        install(TARGETS ${TARGET_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})
#    endif ()

	message(STATUS "BUILDTYPE: ${CMAKE_BUILD_TYPE}")

	#configure_file($ENV{MK_DIR/cmake/modules/mk_install.in} install.cmake @ONLY)

	# Install resources

	#install(TARGETS ${TARGET_NAME} RESOURCE DESTINATION ${BUNDLE_RESOURCE_DIR})

	mk_is_debug_config(IS_DEBUG ${CMAKE_BUILD_TYPE})

    install(CODE "
            set(CMAKE_INSTALL_PREFIX ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
            include(\$ENV{MK_DIR}/cmake/modules/mk_install.cmake)
            mk_install(${TARGET_NAME} $<TARGET_FILE:${TARGET_NAME}> ${IS_DEBUG} SEARCH ${ARGN})
        " COMPONENT Runtime)

endfunction()

# mk_target_link_libraries(<TARGET_NAME> [<...>])
# This macro performs target_link_libraries(${PROJECT} ${LIBRARIES}) and mk_target_deploy_libraries(${LIBRARIES})
# appends the runtime library (.dll; .dylib; .so) of shared libraries to MK_RUNTIME_LIBRARIES
# EXPERIMENTAL
macro(mk_target_link_libraries TARGET_NAME)
	
	target_link_libraries(${TARGET_NAME} ${ARGN})

endmacro()

# mk_target_resources(<TARGET_NAME> [<...>])
# This macro adds FILES to the target's list of resources
macro(mk_target_resources TARGET_NAME)

	set_property(TARGET ${TARGET_NAME} APPEND PROPERTY RESOURCE ${ARGN})

endmacro()

# mk_target_is_bundle(<VAR> <TARGET_NAME>)
function(mk_target_is_bundle VAR TARGET_NAME)

	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (MK_OS_MACOS)

		if (${TARGET_TYPE} STREQUAL "EXECUTABLE") # Executable

			get_target_property(TARGET_IS_BUNDLE ${TARGET_NAME} MACOSX_BUNDLE)

		else () # Library

			get_target_property(TARGET_IS_BUNDLE ${TARGET_NAME} FRAMEWORK)
		
		endif ()

		if (${TARGET_IS_BUNDLE} STREQUAL "NOTFOUND" OR ${TARGET_IS_BUNDLE} STREQUAL "")
			set(TARGET_IS_BUNDLE FALSE)
		endif ()

	else ()
		set(TARGET_IS_BUNDLE FALSE)
	endif ()

	set(${VAR} ${TARGET_IS_BUNDLE} PARENT_SCOPE)

endfunction()
