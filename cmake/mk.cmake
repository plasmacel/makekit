cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

enable_language(C)
enable_language(CXX)

if (MAKEKIT_ASM)
	enable_language(ASM)
endif ()

if (MAKEKIT_CUDA)
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
	set(MAKEKIT_OS_WINDOWS 1)
	set(MAKEKIT_RUNTIME_LIBRARY_EXTENSION .dll)
elseif (CMAKE_HOST_UNIX) # True for UNIX and UNIX like operating systems, including APPLE operation systems and Cygwin.
	set(MAKEKIT_OS_UNIX 1)
	if (CMAKE_HOST_APPLE) # True for Apple macOS operation systems.
		message(STATUS "MakeKit - Detected OS: macOS")
		set(MAKEKIT_OS_MACOS 1)
		set(MAKEKIT_RUNTIME_LIBRARY_EXTENSION .dylib)
	else ()
		message(STATUS "MakeKit - Detected OS: Unix/Linux")
		set(MAKEKIT_OS_LINUX 1)
		set(MAKEKIT_RUNTIME_LIBRARY_EXTENSION .so)
	endif ()
endif ()

#
# Include custom build types (compiler, linker and other flags)
#

include(CustomBuilds.cmake OPTIONAL)

#
# Find source
#

#file(GLOB_RECURSE C_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.c)
#file(GLOB_RECURSE C_HEADERS RELATIVE ${MAKEKIT_SOURCE} *.h)

file(GLOB_RECURSE CXX_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.cc *.cpp *.cxx)
file(GLOB_RECURSE CXX_HEADERS RELATIVE ${MAKEKIT_SOURCE} *.h *.hh *.hpp *.hxx)
file(GLOB_RECURSE CXX_INLINES RELATIVE ${MAKEKIT_SOURCE} *.inc *.inl *.ipp *.ixx *.tcc *.tpp *.txx)
#file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MAKEKIT_SOURCE} *.${CMAKE_CXX_OUTPUT_EXTENSION})
if (MAKEKIT_OS_WINDOWS)
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MAKEKIT_SOURCE} *.obj)
else ()
	file(GLOB_RECURSE CXX_OBJECTS RELATIVE ${MAKEKIT_SOURCE} *.o)
endif ()

if (MAKEKIT_ASM)
	file(GLOB_RECURSE ASM_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.asm *.s)
endif ()
	
if (MAKEKIT_CUDA)
	file(GLOB_RECURSE CUDA_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.cu)
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

function(mk_save_list FILENAME LIST)
	string(REPLACE ";" "\n" LIST_PROCESSED "${LIST}")
	file(WRITE "${CMAKE_BINARY_DIR}/${FILENAME}" "${LIST_PROCESSED}")
endfunction()

set(MAKEKIT_RUNTIME_LIBRARIES "")
set(MAKEKIT_DEPLOY_FILES "")

# This macro adds FILELIST to the list of deploy libraries
macro(mk_deploy_files FILELIST)
	set(MAKEKIT_DEPLOY_FILES ${MAKEKIT_DEPLOY_FILES} ${FILELIST})
	#list(APPEND MAKEKIT_DEPLOY_FILES ${FILELIST})
endmacro()

# This macro appends the runtime library (.dll; .dylib; .so) of shared libraries to MAKEKIT_RUNTIME_LIBRARIES
# It does nothing for non-shared libraries
macro(mk_target_deploy_libraries PROJECT LIBRARIES)
	foreach (LIBRARY "${LIBRARIES}")
		if (TARGET ${LIBRARY}) # LIBRARY is a TARGET
			get_target_property(LIBRARY_TYPE ${LIBRARY} TYPE)
			message(STATUS "MakeKit - Library type: ${LIBRARY_TYPE}")
			if (LIBRARY_TYPE STREQUAL "SHARED_LIBRARY")
				get_target_property(LIBRARY_IMPORTED ${LIBRARY} IMPORTED)
				if (LIBRARY_IMPORTED)
					#message(STATUS "MakeKit - Imported library: ${LIBRARY}")
					get_target_property(LIBRARY_RUNTIME ${LIBRARY} IMPORTED_LOCATION)
					if (NOT LIBRARY_RUNTIME) # IMPORTED_LOCATION is undefined, try LOCATION (it is mandatory for Qt)
						get_target_property(LIBRARY_RUNTIME ${LIBRARY} LOCATION)
					endif ()
				else ()
					#message(STATUS "MakeKit - Not an imported library: ${LIBRARY}")
					get_target_property(LIBRARY_RUNTIME ${LIBRARY} LOCATION)
				endif ()
			else ()
				message(STATUS "MakeKit - Not a shared library: ${LIBRARY}")
				continue() # Go to next iteration
			endif ()
		else () # LIBRARY is a FILEPATH
			if (MAKEKIT_OS_WINDOWS) # Change file extension to .dll
				string(REGEX REPLACE "\\.[^.]*$" ".dll" LIBRARY_RUNTIME ${LIBRARY})
			else ()
				set(LIBRARY_RUNTIME ${LIBRARY})
			endif ()
		endif ()

		message(STATUS "MakeKit - Added runtime library: ${LIBRARY_RUNTIME}")
		set(MAKEKIT_RUNTIME_LIBRARIES ${MAKEKIT_RUNTIME_LIBRARIES} ${LIBRARY_RUNTIME})
		#list(APPEND MAKEKIT_RUNTIME_LIBRARIES ${LIBRARY_RUNTIME})
	endforeach ()
endmacro()

# This macro performs target_link_libraries(${PROJECT} ${LIBRARIES}) and mk_target_deploy_libraries(${LIBRARIES})
# appends the runtime library (.dll; .dylib; .so) of shared libraries to MAKEKIT_RUNTIME_LIBRARIES
macro(mk_target_link_libraries PROJECT LIBRARIES)
	target_link_libraries(${PROJECT} ${LIBRARIES})
	mk_target_deploy_libraries(${LIBRARIES})

	# Add shared libraries to MAKEKIT_RUNTIME_LIBRARIES
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

	set(LIBRARY_SHARED_FILE ${LIBRARY_STATIC_FILE})

	if (MAKEKIT_OS_WINDOWS AND MODE STREQUAL "SHARED")
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
# Qt5
#

if (MAKEKIT_QT)
	file(GLOB_RECURSE CXX_UIFILES RELATIVE ${MAKEKIT_SOURCE} *.ui)
 
	set(CMAKE_AUTOMOC ON)
	set(CMAKE_AUTORCC ON)
	set(CMAKE_AUTOUIC ON)

	set(CMAKE_INCLUDE_CURRENT_DIR ON)
	#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
	#set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
	#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS}")

	set(Qt5_DIR $ENV{MAKEKIT_QT_DIR}/lib/cmake/Qt5)
	find_package(Qt5 COMPONENTS ${MAKEKIT_QT} REQUIRED)

	if (NOT Qt5_FOUND)
		message(FATAL_ERROR "MakeKit - Qt5 cannot be found!")
		return()
	endif ()

	# Not required when CMAKE_AUTOUIC is ON
	#qt5_wrap_ui(CXX_QT_GENS ${CXX_UIFILES})
endif ()

#
# Add target
#

if (CXX_SOURCES)
	if (${MAKEKIT_MODULE_MODE} STREQUAL "NONE")
		return() # Do nothing
	elseif (${MAKEKIT_MODULE_MODE} STREQUAL "EXECUTABLE")
		add_executable(${PROJECT_NAME} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
	else ()
		if (${MAKEKIT_MODULE_MODE} STREQUAL "INTERFACE_LIBRARY")
			set(MAKEKIT_MODULE_VISIBILITY INTERFACE)
		elseif (${MAKEKIT_MODULE_MODE} STREQUAL "STATIC_LIBRARY")
			set(MAKEKIT_MODULE_VISIBILITY STATIC)
		elseif (${MAKEKIT_MODULE_MODE} STREQUAL "SHARED_LIBRARY")
			set(MAKEKIT_MODULE_VISIBILITY SHARED)
		else()
			message(FATAL_ERROR "MakeKit - Invalid MAKEKIT_MODULE_MODE!")
			return()
		endif ()
		
		add_library(${PROJECT_NAME} ${MAKEKIT_MODULE_VISIBILITY} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
		
		# For header-only libraries this line is required
		if (${MAKEKIT_MODULE_MODE} STREQUAL "INTERFACE_LIBRARY")
			target_include_directories(${PROJECT_NAME} INTERFACE ${CXX_HEADERS} ${CXX_INLINES})
		endif ()
	endif ()
	
	# Set C/C++ language standard of the target
	set_property(TARGET ${PROJECT_NAME} PROPERTY C_STANDARD 11)
	set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 17)
else ()
	message(STATUS "MakeKit - No C/C++ sources found.")
	return()
endif ()

#
# Set linker language for cases when it cannot be determined
# (for example when the source consists precompiled object files only)
#

#get_target_property(MAKEKIT_LINKER_LANGUAGE ${PROJECT_NAME} LINKER_LANGUAGE)
#message(${MAKEKIT_LINKER_LANGUAGE})
#if (${MAKEKIT_LINKER_LANGUAGE} STREQUAL "NOTFOUND")
#    set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
#endif()
#set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY LINKER_LANGUAGE CXX)

#
# OpenCL
# https://cmake.org/cmake/help/v3.10/module/FindOpenCL.html
#

if (MAKEKIT_OPENCL)
	find_package(OpenCL REQUIRED)
    
	if (NOT OpenCL_FOUND)
		message(FATAL_ERROR "MakeKit - OpenCL cannot be found!")
		return()
	endif ()
    
	target_link_libraries(${PROJECT_NAME} OpenCL::OpenCL)
	mk_target_deploy_libraries(${PROJECT_NAME} OpenCL::OpenCL)
endif ()

#
# OpenGL
# https://cmake.org/cmake/help/v3.10/module/FindOpenGL.html
#

if (MAKEKIT_OPENGL)
	find_package(OpenGL REQUIRED)
    
	if (NOT OpenGL_FOUND)
		message(FATAL_ERROR "MakeKit - OpenGL cannot be found!")
		return()
	endif ()

	target_link_libraries(${PROJECT_NAME} OpenGL::GL)
	mk_target_deploy_libraries(${PROJECT_NAME} OpenGL::GL)

	#if (OpenGL::OpenGL)
	#	target_link_libraries(${PROJECT_NAME} OpenGL::OpenGL)
	#	mk_target_deploy_libraries(${PROJECT_NAME} OpenGL::OpenGL)
	#else ()
	#	target_link_libraries(${PROJECT_NAME} OpenGL::GL)
	#	mk_target_deploy_libraries(${PROJECT_NAME} OpenGL::GL)
	#endif ()
endif ()

#
# OpenMP
# https://cmake.org/cmake/help/v3.10/module/FindOpenMP.html
#

if (MAKEKIT_OPENMP)
	if (TRUE) # Use LLVM libomp
		set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} "") # Append empty string to the list of library prefixes
		find_library(MAKEKIT_LIBOMP_LIB libomp PATHS $ENV{MAKEKIT_LLVM_DIR}/lib REQUIRED) # add NO_DEFAULT_PATH to restrict to LLVM-installed libomp

		if (NOT MAKEKIT_LIBOMP_LIB)
			message(FATAL_ERROR "MakeKit - OpenMP (libomp) cannot be found!")
			return()
		endif ()
	
		if (MAKEKIT_OS_WINDOWS)
			target_compile_options(${PROJECT_NAME} PRIVATE -Xclang -fopenmp)
		else ()
			target_compile_options(${PROJECT_NAME} PRIVATE -fopenmp=libomp)
		endif ()
		
		target_link_libraries(${PROJECT_NAME} ${MAKEKIT_LIBOMP_LIB})
		mk_target_deploy_libraries(${PROJECT_NAME} ${MAKEKIT_LIBOMP_LIB})
	else ()
		find_package(OpenMP REQUIRED)

		if (NOT OpenMP_FOUND)
			message(FATAL_ERROR "MakeKit - OpenMP cannot be found!")
			return()
		endif ()
		
		target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
		mk_target_deploy_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
	endif ()
endif ()

#
# Vulkan
# https://cmake.org/cmake/help/v3.10/module/FindVulkan.html
#

if (MAKEKIT_VULKAN)
	find_package(Vulkan REQUIRED)
    
	if (NOT Vulkan_FOUND)
		message(FATAL_ERROR "MakeKit - Vulkan cannot be found!")
		return()
	endif ()
    
	target_link_libraries(${PROJECT_NAME} Vulkan::Vulkan)
	mk_target_deploy_libraries(${PROJECT_NAME} Vulkan::Vulkan)
endif ()

#
# Qt
#

if (MAKEKIT_QT)
	foreach (QTMODULE ${MAKEKIT_QT})
		target_link_libraries(${PROJECT_NAME} Qt5::${QTMODULE}) # Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network
		mk_target_deploy_libraries(${PROJECT_NAME} Qt5::${QTMODULE})
	endforeach ()
endif ()

#
# Custom pre-build commands
#

mk_save_list("DeployLists.txt" "${MAKEKIT_RUNTIME_LIBRARIES}")

#
# Post-build deploy
#

if (MAKEKIT_AUTODEPLOY)
	message("MakeKit - Deploying files: ${MAKEKIT_RUNTIME_LIBRARIES}")

	foreach (FILE ${MAKEKIT_RUNTIME_LIBRARIES})
		if (IS_ABSOLUTE ${FILE})
			set(FILE_ABSOLUTE_PATH ${FILE})
		else ()
			find_file(FILE_ABSOLUTE_PATH ${FILE})
		endif ()

		if (FILE_ABSOLUTE_PATH)
			get_filename_component(FILE_NAME ${FILE} NAME)
			add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different ${FILE_ABSOLUTE_PATH} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${FILE_NAME})
		else ()
			message(ERROR "MakeKit - File ${FILE} cannot be found!")
		endif ()
	endforeach ()
endif ()
