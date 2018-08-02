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

cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

message(STATUS "MakeKit - Configuring project ${PROJECT_NAME}...")

if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	#message(FATAL_ERROR "MakeKit - Not a valid LLVM/clang compiler!
	#	You are maybe using Apple's fork of LLVM/clang shipped with Xcode instead of the genuine one.")
	#return()
endif ()

enable_language(C)
enable_language(CXX)

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
# Find source
#
# macro(mk_collect_sources PATH)
# macro(mk_collect_headers PATH)
# macro(mk_collect_inlines PATH)
# macro(mk_collect_objects PATH)

#file(GLOB_RECURSE C_SOURCES RELATIVE ${MK_SOURCE} *.c)
#file(GLOB_RECURSE C_HEADERS RELATIVE ${MK_SOURCE} *.h)

file(GLOB_RECURSE CXX_SOURCES RELATIVE ${MK_SOURCE} *.cc *.c++ *.cpp *.cxx)
file(GLOB_RECURSE CXX_HEADERS RELATIVE ${MK_SOURCE} *.h *.hh *.h++ *.hpp *.hxx)
file(GLOB_RECURSE CXX_INLINES RELATIVE ${MK_SOURCE} *.inc *.inl *.ipp *.ixx *.tpp *.txx)
#file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MK_SOURCE} *.${CMAKE_CXX_OUTPUT_EXTENSION})
if (MK_OS_WINDOWS)
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MK_SOURCE} *.obj)
else ()
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MK_SOURCE} *.o)
endif ()

# Qt related source files
file(GLOB_RECURSE CXX_QRCFILES RELATIVE ${MK_SOURCE} *.qrc)
file(GLOB_RECURSE CXX_UIFILES RELATIVE ${MK_SOURCE} *.ui)

# if ("ASM" IN_LIST ${ENABLED_LANGUAGES})
if (MK_ASM)
	file(GLOB_RECURSE ASM_SOURCES RELATIVE ${MK_SOURCE} *.asm *.s)
endif ()

# if ("CUDA" IN_LIST ${ENABLED_LANGUAGES})
if (MK_CUDA)
	file(GLOB_RECURSE CUDA_SOURCES RELATIVE ${MK_SOURCE} *.cu)
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

#
# Functions and Macros
#

# mk_message(MESSAGE_TYPE MESSAGE)
function(mk_message MESSAGE_TYPE)
	message(${MESSAGE_TYPE} "MakeKit - ${ARGN}")
endfunction()

set(MK_SUPPORTED_LIBRARY_LIST Boost OpenCL OpenGL OpenMP Qt Vulkan)

# mk_library(LIBRARY)
# EXPERIMENTAL function to link a supported library
macro(mk_library LIBRARY)

	if (NOT ${LIBRARY} IN_LIST MK_SUPPORTED_LIBRARY_LIST)
		mk_message(SEND_ERROR "Unsupported library: ${LIBRARY}")
	endif ()

	string(TOUPPER ${LIBRARY} LIBRARY_UPPERCASE)

	set(MK_${LIBRARY_UPPERCASE} ${ARGN})
	include($ENV{MK_DIR}/cmake/libraries/${LIBRARY}.cmake)

endmacro()

# mk_group_sources(ROOT)
# Macro to preserve source files hierarchy in the IDE
# http://www.rtrclass.type.pl/2018-05-29-how-to-setup-opengl-project-with-cmake/
macro(mk_group_sources ROOT)

    file(GLOB CHILDREN RELATIVE ${PROJECT_SOURCE_DIR}/${ROOT} ${PROJECT_SOURCE_DIR}/${ROOT}/*)
    foreach (CHILD ${CHILDREN})
        if (IS_DIRECTORY ${PROJECT_SOURCE_DIR}/${ROOT}/${CHILD})
            mk_group_sources(${ROOT}/${CHILD})
        else ()
            string(REPLACE "/" "\\" GROUP_NAME ${ROOT})
            string(REPLACE "src" "Sources" GROUP_NAME ${GROUP_NAME})
            source_group(${GROUP_NAME} FILES ${PROJECT_SOURCE_DIR}/${ROOT}/${CHILD})
        endif ()
    endforeach ()

endmacro()

# mk_save_list(FILENAME LIST)
function(mk_save_list FILENAME LIST)

	string(REPLACE ";" "\n" LIST_PROCESSED "${LIST}")
	file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}" "${LIST_PROCESSED}")

endfunction()

set(MK_${PROJECT}_RUNTIME_LIBRARIES "")
set(MK_DEPLOY_FILES "")

# mk_deploy_files(LIST)
# This macro adds FILELIST to the list of deploy libraries
macro(mk_deploy_files LIST)

	set(MK_DEPLOY_FILES ${MK_DEPLOY_FILES} ${LIST})
	#list(APPEND MK_DEPLOY_FILES ${LIST})

endmacro()

# mk_target_deploy_libraries(PROJECT LIBRARIES)
# This macro appends the runtime library (.dll; .dylib; .so) of shared libraries to MK_RUNTIME_LIBRARIES
# It does nothing for non-shared libraries
# TODO rename parameter PROJECT to TARGET_NAME
macro(mk_target_deploy_libraries PROJECT LIBRARIES)

	foreach (LIBRARY "${LIBRARIES}")
		if (TARGET ${LIBRARY}) # LIBRARY is a TARGET
			get_target_property(LIBRARY_TYPE ${LIBRARY} TYPE)
			#mk_message(STATUS "Library type: ${LIBRARY_TYPE}")
			if (LIBRARY_TYPE STREQUAL "SHARED_LIBRARY")
				get_target_property(LIBRARY_IMPORTED ${LIBRARY} IMPORTED)

				if (LIBRARY_IMPORTED)
					#mk_message(STATUS "Imported library: ${LIBRARY}")

					string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_LOWERCASE)

					# try IMPORTED_LOCATION_<CONFIG> (it is mandatory for Qt)
					if (${CMAKE_BUILD_TYPE_LOWERCASE} MATCHES "debug")
						get_target_property(LIBRARY_RUNTIME ${LIBRARY} IMPORTED_LOCATION_DEBUG)
					else ()
						get_target_property(LIBRARY_RUNTIME ${LIBRARY} IMPORTED_LOCATION_RELEASE)
					endif ()
					
					# if IMPORTED_LOCATION_<CONFIG> property is undefined, try LOCATION_<CONFIG>
					if (NOT LIBRARY_RUNTIME)
						if (${CMAKE_BUILD_TYPE_LOWERCASE} MATCHES "debug")
							get_target_property(LIBRARY_RUNTIME ${LIBRARY} LOCATION_DEBUG)
						else ()
							get_target_property(LIBRARY_RUNTIME ${LIBRARY} LOCATION_RELEASE)
						endif ()
					endif ()

					# if LOCATION_<CONFIG> property is undefined, try IMPORTED_LOCATION
					if (NOT LIBRARY_RUNTIME)
						get_target_property(LIBRARY_RUNTIME ${LIBRARY} IMPORTED_LOCATION)
					endif ()

					# if IMPORTED_LOCATION property is undefined, try LOCATION
					if (NOT LIBRARY_RUNTIME)
						get_target_property(LIBRARY_RUNTIME ${LIBRARY} LOCATION)
					endif ()
				else ()
					#mk_message(STATUS "Not an imported library: ${LIBRARY}")
					get_target_property(LIBRARY_RUNTIME ${LIBRARY} LOCATION)
				endif ()
			else ()
				#mk_message(STATUS "Not a shared library: ${LIBRARY}")
				continue() # Go to next iteration
			endif ()
		else () # LIBRARY is a FILEPATH
			if (MK_OS_WINDOWS) # Find corresponding .dll in ${LIBRARY_DIRECTORY} or ${LIBRARY_DIRECTORY}/../bin
				get_filename_component(LIBRARY_DIRECTORY ${LIBRARY} DIRECTORY)
				get_filename_component(LIBRARY_NAME ${LIBRARY} NAME_WE)
				find_file(LIBRARY_RUNTIME ${LIBRARY_NAME}.dll PATHS ${LIBRARY_DIRECTORY} ${LIBRARY_DIRECTORY}/../bin NO_DEFAULT_PATH REQUIRED)
			else () # The corresponding ruintime library is the library itself
				get_filename_component(LIBRARY_EXT ${LIBRARY} EXT)
				if (LIBRARY_EXT IN_LIST ".dylib;.so")
					set(LIBRARY_RUNTIME ${LIBRARY})
				endif ()
			endif ()
		endif ()

		if (LIBRARY_RUNTIME)
			#mk_message(STATUS "Added runtime library: ${LIBRARY_RUNTIME}")
			set(MK_${PROJECT}_RUNTIME_LIBRARIES ${MK_${PROJECT}_RUNTIME_LIBRARIES} ${LIBRARY_RUNTIME})
			#list(APPEND MK_RUNTIME_LIBRARIES ${LIBRARY_RUNTIME})
		endif ()
	endforeach ()

endmacro()

# mk_target_link_libraries(PROJECT LIBRARIES)
# This macro performs target_link_libraries(${PROJECT} ${LIBRARIES}) and mk_target_deploy_libraries(${LIBRARIES})
# appends the runtime library (.dll; .dylib; .so) of shared libraries to MK_RUNTIME_LIBRARIES
# EXPERIMENTAL
macro(mk_target_link_libraries PROJECT LIBRARIES)

	target_link_libraries(${PROJECT} ${LIBRARIES})
	mk_target_deploy_libraries(${LIBRARIES})

endmacro()

# mk_add_build_type(NAME INHERIT C_FLAGS CXX_FLAGS EXE_LINKER_FLAGS SHARED_LINKER_FLAGS STATIC_LINKER_FLAGS)
macro(mk_add_build_type NAME INHERIT C_FLAGS CXX_FLAGS EXE_LINKER_FLAGS SHARED_LINKER_FLAGS STATIC_LINKER_FLAGS)

	set(MK_PROTECTED_BUILD_TYPES None Debug Release RelWithDebInfo MinSizeRel)

	# TODO TOLOWER compare
	if (${NAME} IN_LIST ${MK_PROTECTED_BUILD_TYPES})
		mk_message(FATAL_ERROR "Protected build type: ${NAME}")	
	endif ()

	set(CMAKE_C_FLAGS_${NAME} "${CMAKE_C_FLAGS_${INHERIT}} ${C_FLAGS}"
		CACHE STRING "Flags used by the C compiler during ${NAME} builds"
		FORCE)

	set(CMAKE_CXX_FLAGS_${NAME} "${CMAKE_CXX_FLAGS_${INHERIT}} ${CXX_FLAGS}"
		CACHE STRING "Flags used by the CXX compiler during ${NAME} builds"
		FORCE)

	set(CMAKE_EXE_LINKER_FLAGS_${NAME} "CMAKE_EXE_LINKER_FLAGS_${INHERIT} ${EXE_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of executables during ${NAME} builds"
		FORCE)

	set(CMAKE_SHARED_LINKER_FLAGS_${NAME} "CMAKE_SHARED_LINKER_FLAGS_${INHERIT} ${SHARED_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of shared libraries during ${NAME} builds"
		FORCE)

	set(CMAKE_STATIC_LINKER_FLAGS_${NAME} "CMAKE_STATIC_LINKER_FLAGS_${INHERIT} ${STATIC_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of static libraries during ${NAME} builds"
		FORCE)

	mark_as_advanced(
		CMAKE_CXX_FLAGS_${NAME}
		CMAKE_C_FLAGS_${NAME}
		CMAKE_EXE_LINKER_FLAGS_${NAME}
		CMAKE_SHARED_LINKER_FLAGS_${NAME})

	# Update the documentation string of CMAKE_BUILD_TYPE for GUIs
	set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}"
		CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel ${NAME}"
		FORCE)

	if (CMAKE_CONFIGURATION_TYPES) # This is defined for multi-configuration generators
		set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES} ${NAME}"
			CACHE STRING ""
			FORCE)
		#list(APPEND CMAKE_CONFIGURATION_TYPES ${NAME})
	endif ()

	# If ${NAME} is a debug configuration, then add it to the list DEBUG_CONFIGURATIONS
	if (${INHERIT} MATCHES "DEBUG")
		#set(DEBUG_CONFIGURATIONS "${DEBUG_CONFIGURATIONS} ${NAME}"
		#	CACHE STRING ""
		#	FORCE)
		list(APPEND DEBUG_CONFIGURATIONS ${NAME})
	endif()

endmacro()

# mk_add_imported_library(NAME MODE LIBRARY_INCLUDE_DIRECTORIES [LIBRARY_STATIC_IMPORT])
# where MODE can be INTERFACE, STATIC, SHARED
# TODO check too much arguments
macro(mk_add_imported_library NAME MODE LIBRARY_INCLUDE_DIRECTORIES)

	add_library(${NAME} ${MODE} IMPORTED GLOBAL)

	set_target_properties(
		${NAME} PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES ${LIBRARY_INCLUDE_DIRECTORIES}
	)

	if (${ARGC} GREATER 3)
		set(LIBRARY_STATIC_IMPORT ${ARGV3})

		# Get extension

		get_filename_component(IMPORTED_LIBRARY_EXT ${LIBRARY_STATIC_IMPORT} EXT)

		# Find platform-specific library file and set LIBRARY_STATIC_FILE

		if (IMPORTED_LIBRARY_EXT)
			set(LIBRARY_STATIC_FILE ${LIBRARY_STATIC_IMPORT})
		else ()
			get_filename_component(IMPORTED_LIBRARY_DIRECTORY ${LIBRARY_STATIC_IMPORT} DIRECTORY)
			get_filename_component(IMPORTED_LIBRARY_NAME ${LIBRARY_STATIC_IMPORT} NAME_WE)

			set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} "") # Append empty string to the list of library prefixes
			find_library(LIBRARY_STATIC_FILE ${IMPORTED_LIBRARY_NAME} PATHS ${IMPORTED_LIBRARY_DIRECTORY} NO_DEFAULT_PATH REQUIRED)
		endif ()
	
		if (LIBRARY_STATIC_FILE)
			mk_message(STATUS "${NAME} found: ${LIBRARY_STATIC_FILE}")
		else ()
			mk_message(FATAL_ERROR "${NAME} cannot be found!")
			return()
		endif ()

		set(LIBRARY_SHARED_FILE ${LIBRARY_STATIC_FILE})

		if (MK_OS_WINDOWS AND ${MODE} STREQUAL "SHARED")
			string(REGEX REPLACE "\\.[^.]*$" ".dll" LIBRARY_SHARED_FILE ${LIBRARY_STATIC_FILE})
		endif ()

		set_target_properties(
			${NAME} PROPERTIES
			IMPORTED_LOCATION ${LIBRARY_SHARED_FILE}
			IMPORTED_IMPLIB ${LIBRARY_STATIC_FILE}
		)
	endif()
	
endmacro()

#
# Add target
#
# macro(mk_add_target NAME TYPE SOURCES)

if (CXX_SOURCES)
	if (${MK_MODULE_MODE} STREQUAL "NONE")
		return() # Do nothing
	elseif (${MK_MODULE_MODE} STREQUAL "EXECUTABLE")

		add_executable(${PROJECT_NAME} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_QRCFILES} ${CXX_UIFILES})

		# Set poperties to build as native GUI application
		# https://cmake.org/cmake/help/latest/prop_tgt/MACOSX_BUNDLE.html
		# https://cmake.org/cmake/help/latest/prop_tgt/MACOSX_BUNDLE_INFO_PLIST.html
		# https://cmake.org/cmake/help/latest/prop_tgt/WIN32_EXECUTABLE.html
		if (MK_NATIVE_GUI_API)
			if (MK_OS_WINDOWS)
				set_target_properties(
					${PROJECT_NAME} PROPERTIES
					WIN32_EXECUTABLE TRUE
				)
			elseif (MK_OS_MACOS)
				set_target_properties(
					${PROJECT_NAME} PROPERTIES
					MACOSX_BUNDLE TRUE
					MACOSX_BUNDLE_INFO_PLIST ${MK_MACOS_BUNDLE_INFO_PLIST}
				)
			endif ()
		endif ()
	else ()
		if (${MK_MODULE_MODE} STREQUAL "INTERFACE_LIBRARY")
			set(MK_MODULE_VISIBILITY INTERFACE)
		elseif (${MK_MODULE_MODE} STREQUAL "STATIC_LIBRARY")
			set(MK_MODULE_VISIBILITY STATIC)
		elseif (${MK_MODULE_MODE} STREQUAL "SHARED_LIBRARY")
			set(MK_MODULE_VISIBILITY SHARED)
		else()
			mk_message(FATAL_ERROR "Invalid MK_MODULE_MODE!")
			return()
		endif ()
		
		add_library(${PROJECT_NAME} ${MK_MODULE_VISIBILITY} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_QRCFILES} ${CXX_UIFILES})
		
		# For header-only libraries this line is required
		if (${MK_MODULE_MODE} STREQUAL "INTERFACE_LIBRARY")
			target_include_directories(${PROJECT_NAME} INTERFACE ${CXX_HEADERS} ${CXX_INLINES})
		endif ()

		#TODO
		#set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_FRAMEWORK_INFO_PLIST ${MK_MACOS_FRAMEWORK_INFO_PLIST})
	endif ()
	
	# Set C/C++ language standard of the target
	set_property(TARGET ${PROJECT_NAME} PROPERTY C_STANDARD 11)
	set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)

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

		target_link_libraries(${PROJECT_NAME} Threads::Threads)
	endif ()
else ()
	mk_message(STATUS "No C/C++ sources found.")
	return()
endif ()

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

#
# Pre-build commands
#

#
# Post-build deploy
#

# mk_deploy_list()
macro(mk_deploy_list)
	mk_save_list("DeployLists.txt" "${MK_${PROJECT_NAME}_RUNTIME_LIBRARIES}")
endmacro()

# mk_deploy()
macro(mk_deploy)

	mk_message(STATUS "Deploying files: ${MK_${PROJECT_NAME}_RUNTIME_LIBRARIES}")

	foreach (FILE ${MK_${PROJECT_NAME}_RUNTIME_LIBRARIES})
		if (IS_ABSOLUTE ${FILE})
			set(FILE_ABSOLUTE_PATH ${FILE})
		else ()
			find_file(FILE_ABSOLUTE_PATH ${FILE})
		endif ()

		if (FILE_ABSOLUTE_PATH)
			get_filename_component(FILE_NAME ${FILE} NAME)
			add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different ${FILE_ABSOLUTE_PATH} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${FILE_NAME})
		else ()
			mk_message(SEND_ERROR "File ${FILE} cannot be found!")
		endif ()
	endforeach ()

endmacro()
