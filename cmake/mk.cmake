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
# Language standard
#

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

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
# Excluding CMake generated files from source for safety
#

list(FILTER CXX_SOURCES EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_HEADERS EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_INLINES EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_OBJECTS EXCLUDE REGEX ".*CMakeFiles/.*")

#
# Macros
#

set(MAKEKIT_DEPLOY_FILES "")

macro(makekit_runtime_libraries LIBRARIES)
    foreach (LIBRARY "${LIBRARIES}")
        get_property(LIBRARY_IMPORTED TARGET ${LIBRARY} PROPERTY IMPORTED)
        
	if (LIBRARY_IMPORTED)
	    get_property(LIBRARY TARGET ${LIBRARY} PROPERTY IMPORTED_LOCATION_RELEASE)
	    #get_property(LIBRARY TARGET ${LIBRARY} PROPERTY IMPORTED_LOCATION)
	    #get_property(LIBRARY TARGET ${LIBRARY} PROPERTY LOCATION)
	endif ()
	
        if (MAKEKIT_OS_WINDOWS) # Change extension to DLL
            string(REGEX REPLACE "\\.[^.]*$" ".dll" LIBRARY_RUNTIME ${LIBRARY})
	else ()
	    set(LIBRARY_RUNTIME ${LIBRARY})
	endif ()
	
        set(MAKEKIT_DEPLOY_FILES ${MAKEKIT_DEPLOY_FILES} ${LIBRARY_RUNTIME})
        #list(APPEND MAKEKIT_DEPLOY_FILES ${LIBRARY_RUNTIME})
    endforeach ()
endmacro()

macro(makekit_deploy_libraries LIBRARIES)
    set(MAKEKIT_DEPLOY_FILES ${MAKEKIT_DEPLOY_FILES} ${LIBRARIES})
    #list(APPEND MAKEKIT_DEPLOY_FILES ${LIBRARIES})
endmacro()

macro(makekit_deploy_imported_libraries LIBRARIES)
    foreach (LIBRARY "${LIBRARIES}")
        get_property(LIBRARY_IMPORTED_LOCATION TARGET ${LIBRARY} PROPERTY IMPORTED_LOCATION_RELEASE)
        message(STATUS "MakeKit - Adding to deploy list: ${LIBRARY_IMPORTED_LOCATION}")
	makekit_deploy_libraries(${LIBRARY_IMPORTED_LOCATION})
    endforeach ()
endmacro()

# MODE can be STATIC, SHARED
macro(makekit_import_library NAME MODE LOCATION)
    add_library(${NAME} $(MODE) IMPORTED GLOBAL)
    set_target_properties(${NAME} PROPERTIES IMPORTED_LOCATION ${LOCATION})
    set_target_properties(${NAME} PROPERTIES IMPORTED_IMPLIB ${LOCATION})
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
else ()
    message(STATUS "MakeKit - No C/C++ sources found.")
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
    
    if (OpenGL::OpenGL)
	target_link_libraries(${PROJECT_NAME} OpenGL::OpenGL)
    else ()
	target_link_libraries(${PROJECT_NAME} OpenGL::GL)
    endif ()
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
	    target_compile_options(${PROJECT_NAME} -Xclang -fopenmp=libomp)
        else ()
	    target_compile_options(${PROJECT_NAME} -fopenmp=libomp)
        endif ()
	
	target_link_libraries(${PROJECT_NAME} ${MAKEKIT_LIBOMP_LIB})
        makekit_deploy_libraries(${MAKEKIT_LIBOMP_LIB})
    else ()
        find_package(OpenMP REQUIRED)
	
        if (NOT OpenMP_FOUND)
            message(FATAL_ERROR "MakeKit - OpenMP cannot be found!")
	    return()
        endif ()
	
	target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
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
endif ()

#
# Qt
#

if (MAKEKIT_QT)
    foreach (QTMODULE ${MAKEKIT_QT})
        target_link_libraries(${PROJECT_NAME} Qt5::${QTMODULE}) # Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network
        #makekit_copy_shared_library(${PROJECT_NAME} Qt5::${QTMODULE})
	makekit_deploy_imported_libraries(Qt5::${QTMODULE})
    endforeach ()
endif ()

#
# Custom pre-build commands
#

#
# Post-build deploy
#

if (MAKEKIT_AUTODEPLOY)
    message("MakeKit - Deploying files: ${MAKEKIT_DEPLOY_FILES}")

    foreach (FILE ${MAKEKIT_DEPLOY_FILES})
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
