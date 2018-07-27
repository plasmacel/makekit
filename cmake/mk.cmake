cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

message(STATUS "MakeKit - Configuring project ${PROJECT_NAME}...")

if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	message(FATAL_ERROR "MakeKit - Not a valid LLVM/clang compiler!
		You are maybe using Apple's fork of LLVM/clang shipped with Xcode instead of the genuine one.")
	return()
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

#file(GLOB_RECURSE C_SOURCES RELATIVE ${MK_SOURCE} *.c)
#file(GLOB_RECURSE C_HEADERS RELATIVE ${MK_SOURCE} *.h)

file(GLOB_RECURSE CXX_SOURCES RELATIVE ${MK_SOURCE} *.c++ *.cc *.cpp *.cxx)
file(GLOB_RECURSE CXX_HEADERS RELATIVE ${MK_SOURCE} *.h *.h++ *.hh *.hpp *.hxx)
file(GLOB_RECURSE CXX_INLINES RELATIVE ${MK_SOURCE} *.inc *.inl *.ipp *.ixx *.tcc *.tpp *.txx)
#file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MK_SOURCE} *.${CMAKE_CXX_OUTPUT_EXTENSION})
if (MK_OS_WINDOWS)
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MK_SOURCE} *.obj)
else ()
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MK_SOURCE} *.o)
endif ()

# Qt related source files
file(GLOB_RECURSE CXX_QRCFILES RELATIVE ${MK_SOURCE} *.qrc)
file(GLOB_RECURSE CXX_UIFILES RELATIVE ${MK_SOURCE} *.ui)

if (MK_ASM)
	file(GLOB_RECURSE ASM_SOURCES RELATIVE ${MK_SOURCE} *.asm *.s)
endif ()
	
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

function(mk_message MESSAGE_TYPE)
	message(${MESSAGE_TYPE} "MakeKit - ${ARGN}")
endfunction()

set(MK_SUPPORTED_LIBRARY_LIST OpenCL OpenGL OpenMP Qt Vulkan)

macro(mk_library LIBRARY)
	if (NOT ${LIBRARY} IN_LIST MK_SUPPORTED_LIBRARY_LIST)
		mk_message(SEND_ERROR "Unsupported library: ${LIBRARY}")
	endif ()

	string(TOUPPER ${LIBRARY} LIBRARY_UPPERCASE)

	set(MK_${LIBRARY_UPPERCASE} ${ARGN})
	include($ENV{MAKEKIT_DIR}/cmake/libraries/${LIBRARY}.cmake)
endmacro()

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

function(mk_save_list FILENAME LIST)
	string(REPLACE ";" "\n" LIST_PROCESSED "${LIST}")
	file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${FILENAME}" "${LIST_PROCESSED}")
endfunction()

set(MK_${PROJECT}_RUNTIME_LIBRARIES "")
set(MK_DEPLOY_FILES "")

# This macro adds FILELIST to the list of deploy libraries
macro(mk_deploy_files FILELIST)
	set(MK_DEPLOY_FILES ${MK_DEPLOY_FILES} ${FILELIST})
	#list(APPEND MK_DEPLOY_FILES ${FILELIST})
endmacro()

# This macro appends the runtime library (.dll; .dylib; .so) of shared libraries to MK_RUNTIME_LIBRARIES
# It does nothing for non-shared libraries
macro(mk_target_deploy_libraries PROJECT LIBRARIES)
	foreach (LIBRARY "${LIBRARIES}")
		if (TARGET ${LIBRARY}) # LIBRARY is a TARGET
			get_target_property(LIBRARY_TYPE ${LIBRARY} TYPE)
			mk_message(STATUS "Library type: ${LIBRARY_TYPE}")
			if (LIBRARY_TYPE STREQUAL "SHARED_LIBRARY")
				get_target_property(LIBRARY_IMPORTED ${LIBRARY} IMPORTED)
				if (LIBRARY_IMPORTED)
					#mk_message(STATUS "Imported library: ${LIBRARY}")
					get_target_property(LIBRARY_RUNTIME ${LIBRARY} IMPORTED_LOCATION)
					if (NOT LIBRARY_RUNTIME) # IMPORTED_LOCATION is undefined, try LOCATION (it is mandatory for Qt)
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

# This macro performs target_link_libraries(${PROJECT} ${LIBRARIES}) and mk_target_deploy_libraries(${LIBRARIES})
# appends the runtime library (.dll; .dylib; .so) of shared libraries to MK_RUNTIME_LIBRARIES
macro(mk_target_link_libraries PROJECT LIBRARIES)
	target_link_libraries(${PROJECT} ${LIBRARIES})
	mk_target_deploy_libraries(${LIBRARIES})

	# Add shared libraries to MK_RUNTIME_LIBRARIES
	#foreach (LIBRARY "${LIBRARIES}")
	#	if (TARGET ${LIBRARY}) # LIBRARY is a TARGET
	#		get_target_property(LIBRARY_TYPE ${LIBRARY} TYPE)
	#		if (LIBRARY_TYPE STREQUAL "SHARED_LIBRARY") # LIBRARY is a SHARED_LIBRARY TARGET
	#			mk_shared_libraries(${LIBRARY})
	#		endif ()
	#	endif ()
	#endforeach ()
endmacro()

# MODE can be STATIC, SHARED
macro(mk_import_shared_library NAME LIBRARY_INCLUDE_DIRECTORIES LIBRARY_SHARED_IMPORT LIBRARY_STATIC_IMPORT)
	add_library(${NAME} SHARED IMPORTED GLOBAL)
	
	if (NOT LIBRARY_STATIC_IMPORT) # In case of macOS and Linux, .dylib and .so files are needed for linking
		set(LIBRARY_STATIC_IMPORT ${LIBRARY_SHARED_IMPORT})
	endif ()

	set_target_properties(
		${NAME} PROPERTIES
		INTERFACE_INCLUDE_DIRECTORIES ${LIBRARY_INCLUDE_DIRECTORIES}
		IMPORTED_LOCATION ${LIBRARY_SHARED_IMPORT}
		IMPORTED_IMPLIB ${LIBRARY_STATIC_IMPORT}
	)
endmacro()

macro(mk_add_imported_library NAME MODE LIBRARY_INCLUDE_DIRECTORIES LIBRARY_STATIC_IMPORT)
	add_library(${NAME} ${MODE} IMPORTED GLOBAL)

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
		INTERFACE_INCLUDE_DIRECTORIES ${LIBRARY_INCLUDE_DIRECTORIES}
		IMPORTED_LOCATION ${LIBRARY_SHARED_FILE}
		IMPORTED_IMPLIB ${LIBRARY_STATIC_FILE}
	)
endmacro()

#
# Add target
#	

if (CXX_SOURCES)
	if (${MK_MODULE_MODE} STREQUAL "NONE")
		return() # Do nothing
	elseif (${MK_MODULE_MODE} STREQUAL "EXECUTABLE")
		add_executable(${PROJECT_NAME} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_QRCFILES} ${CXX_UIFILES})
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
		
		add_library(${PROJECT_NAME} ${MK_MODULE_VISIBILITY} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
		
		# For header-only libraries this line is required
		if (${MK_MODULE_MODE} STREQUAL "INTERFACE_LIBRARY")
			target_include_directories(${PROJECT_NAME} INTERFACE ${CXX_HEADERS} ${CXX_INLINES})
		endif ()
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

include($ENV{MAKEKIT_DIR}/cmake/libraries/OpenCL.cmake)
include($ENV{MAKEKIT_DIR}/cmake/libraries/OpenGL.cmake)
include($ENV{MAKEKIT_DIR}/cmake/libraries/OpenMP.cmake)
include($ENV{MAKEKIT_DIR}/cmake/libraries/Qt.cmake)
include($ENV{MAKEKIT_DIR}/cmake/libraries/Vulkan.cmake)

#
# Pre-build commands
#

#
# Post-build deploy
#

macro(mk_deploy_list)
	mk_save_list("DeployLists.txt" "${MK_${PROJECT_NAME}_RUNTIME_LIBRARIES}")
endmacro()

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
