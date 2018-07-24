cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

project(untitled)

# MakeKit Variables
#set(MAKEKIT_ASM 1)
#set(MAKEKIT_CUDA 1)
#set(MAKEKIT_OPENCL 1)
#set(MAKEKIT_OPENGL 1)
#set(MAKEKIT_OPENMP 1)
#set(MAKEKIT_VULKAN 1)
#set(MAKEKIT_QT core) # core gui opengl widgets network

set(MAKEKIT_MODULE_MODE 4)
set(MAKEKIT_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})

enable_language(C)
enable_language(CXX)

if (MAKEKIT_ASM)
    enable_language(ASM)
endif ()

if (MAKEKIT_CUDA)
    enable_language(CUDA)
endif ()

# Set output directories

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

# Language Standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# OS Platform Detection
if (CMAKE_HOST_WIN32) # True if the host system is running Windows, including Windows 64-bit and MSYS, but false on Cygwin.
    set(MAKEKIT_OS_WINDOWS, 1)
elseif (CMAKE_HOST_UNIX) # True for UNIX and UNIX like operating systems, including APPLE operation systems and Cygwin.
    set(MAKEKIT_OS_UNIX, 1)
    if (CMAKE_HOST_APPLE) # True for Apple macOS operation systems.
        set(MAKEKIT_OS_MACOS, 1)
    else ()
        set(MAKEKIT_OS_LINUX, 1)
    endif ()
endif ()

# Include custom build types (compiler, linker and other flags)
#set(CMAKE_CXX_FLAGS "/DWIN64 /D_WINDOWS /Wall /GR /EHsc" CACHE INTERNAL "")
#set (CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/CompilerOptions.cmake")
include(custom_builds.cmake)

# Find source
file(GLOB_RECURSE CXX_SOURCES RELATIVE ${MAKEKIT_SOURCE} *.cc *.cpp *.cxx)
file(GLOB_RECURSE CXX_HEADERS RELATIVE ${MAKEKIT_SOURCE} *.h *.hh *.hpp *.hxx)
file(GLOB_RECURSE CXX_INLINES RELATIVE ${MAKEKIT_SOURCE} *.inc *.inl *.ipp *.ixx *.tcc *.tpp *.txx)
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

# Excluding CMake generated files for safety
list(FILTER CXX_SOURCES EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_HEADERS EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_INLINES EXCLUDE REGEX ".*CMakeFiles/.*")
list(FILTER CXX_OBJECTS EXCLUDE REGEX ".*CMakeFiles/.*")

# Macros
macro(makekit_copy_shared_library PROJECT LIBRARY)
    add_custom_command(TARGET ${PROJECT} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:${LIBRARY}> $<TARGET_FILE_DIR:${PROJECT}>)
endmacro()

# ------------------------------ Qt related stuff ------------------------------
if (MAKEKIT_QT)
    file(GLOB_RECURSE CXX_UIFILES RELATIVE ${MAKEKIT_SOURCE} *.ui)
 
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_AUTOUIC ON)

    set(CMAKE_INCLUDE_CURRENT_DIR ON)
    #set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS}")

    if (MAKEKIT_OS_WINDOWS)
        if (MSYS)
	    # Using MSYS MinGW-w64 toolchain, CMake will automatically find the Qt5 CMake configs
            #set(Qt5_DIR "C:/msys64/mingw64/lib/cmake/Qt5/")
        else ()
	    # Using Visual C++ toolchain
            set(Qt5_DIR "C:/Qt/5.10.0/msvc2017_64/lib/cmake/Qt5/")
        endif ()
    endif ()

    find_package(Qt5 COMPONENTS ${MAKEKIT_QT} REQUIRED)

    if (NOT Qt5_FOUND)
        message(FATAL_ERROR Qt5 cannot be found!)
    endif ()

    # Not required when CMAKE_AUTOUIC is ON
    #qt5_wrap_ui(CXX_QT_GENS ${CXX_UIFILES})
endif ()

# ------------------------------ End of Qt related stuff ------------------------------

# Add target

if (CXX_SOURCES)
    if (${MAKEKIT_MODULE_MODE} EQUAL 0)
            # Do nothing
    elseif (${MAKEKIT_MODULE_MODE} LESS 4)
            if (${MAKEKIT_MODULE_MODE} EQUAL 1)
                    set(MAKEKIT_MODULE_VISIBILITY INTERFACE)
            elseif (${MAKEKIT_MODULE_MODE} EQUAL 2)
                    set(MAKEKIT_MODULE_VISIBILITY STATIC)
            elseif (${MAKEKIT_MODULE_MODE} EQUAL 3)
                    set(MAKEKIT_MODULE_VISIBILITY SHARED)
            endif()

            add_library(${PROJECT_NAME} ${MAKEKIT_MODULE_VISIBILITY} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
            
	    # For header-only libraries this line is required
	    #target_include_directories(${PROJECT_NAME} INTERFACE ${CXX_HEADERS} ${CXX_INLINES})
    else ()
            add_executable(${PROJECT_NAME} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
    endif ()
else ()
    message("MakeKit: No C/C++ sources found.")
endif ()

# Set linker language for cases when it cannot be determined
# (for example when the source consists precompiled object files only)
#get_target_property(MAKEKIT_LINKER_LANGUAGE ${PROJECT_NAME} LINKER_LANGUAGE)
#message(${MAKEKIT_LINKER_LANGUAGE})
#if (${MAKEKIT_LINKER_LANGUAGE} STREQUAL "NOTFOUND")
#    set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
#endif()
#set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY LINKER_LANGUAGE CXX)

# Linked libraries

# OpenCL
# https://cmake.org/cmake/help/v3.10/module/FindOpenCL.html
if (MAKEKIT_OPENCL)
    find_package(OpenCL REQUIRED)
    if (OpenCL_FOUND)
        target_link_libraries(${PROJECT_NAME} OpenCL::OpenCL)
    else ()
	message(FATAL_ERROR OpenCL cannot be found!)
    endif ()
endif ()

# OpenGL
# https://cmake.org/cmake/help/v3.10/module/FindOpenGL.html
if (MAKEKIT_OPENGL)
    find_package(OpenGL REQUIRED)
    if (OpenGL_FOUND)
        target_link_libraries(${PROJECT_NAME} OpenGL::OpenGL)
	#target_link_libraries(${PROJECT_NAME} OPENGL_gl_LIBRARY)
        #target_link_libraries(${PROJECT_NAME} OPENGL_glu_LIBRARY)
    else ()
	message(FATAL_ERROR OpenGL cannot be found!)
    endif ()
endif ()

# OpenMP
# https://cmake.org/cmake/help/v3.10/module/FindOpenMP.html
if (MAKEKIT_OPENMP)
    if (MAKEKIT_OS_WINDOWS)
	set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Xclang -fopenmp")
	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Xclang -fopenmp")
	target_link_libraries(${PROJECT_NAME} "C:/Program Files/LLVM/lib/libomp.lib")
    else ()
        set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp")
	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
	#target_link_libraries(${PROJECT_NAME} "libomp.dylib")
    endif()
    #find_package(OpenMP REQUIRED)
    #if (OPENMP_FOUND)
	#	set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
	#	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	#	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${OpenMP_SHARED_LINKER_FLAGS}")
	#	set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
    #endif ()
    #TODO copy openmp runtime library to the bin output
endif ()

# Vulkan
if (MAKEKIT_VULKAN)
    find_package(Vulkan REQUIRED)
    if (Vulkan_FOUND)
        target_link_libraries(${PROJECT_NAME} Vulkan::Vulkan)
    else ()
	message(FATAL_ERROR Vulkan cannot be found!)
    endif ()
endif ()

if (MAKEKIT_QT)
    foreach (QTMODULE ${MAKEKIT_QT})
        target_link_libraries(${PROJECT_NAME} Qt5::${QTMODULE}) # Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network
        makekit_copy_shared_library(${PROJECT_NAME} Qt5::${QTMODULE})
    endforeach ()
endif ()

# Custom libraries

#target_link_libraries(${PROJECT_NAME} mylib.lib)

# Custom pre-build commands


# Custom post-build commands


# ------------------------------ Qt related stuff ------------------------------

if (0)
	
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTOUIC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_INCLUDE_CURRENT_DIR ON)

    #set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS}")

    # Use CMAKE_PREFIX_PATH
    #set(CMAKE_PREFIX_PATH "C:/Qt/5.10.0/msvc2017_64/lib/cmake/Qt5/")
    #set(CMAKE_PREFIX_PATH "C:/msys64/mingw64/lib/cmake/Qt5/")

    if (MAKEKIT_OS_WINDOWS)
        if (MSYS)
	    # Using MSYS MinGW-w64 toolchain, CMake will automatically find the Qt5 CMake configs
            #set(Qt5_DIR "C:/msys64/mingw64/lib/cmake/Qt5/")
        else ()
	    # Using Visual C++ toolchain
            set(Qt5_DIR "C:/Qt/5.10.0/msvc2017_64/lib/cmake/Qt5/")
        endif ()
    endif ()

    find_package(Qt5 REQUIRED COMPONENTS Core)
    target_link_libraries(${PROJECT_NAME} Qt5::Core)
    #target_link_libraries(${PROJECT_NAME} ${Qt5Core_LIBRARIES} Qt5::Core ${MYPROJECT_LIBRARIES})
    #or
    #find_package(Qt5Core REQUIRED)
    #qt5_use_modules(${PROJECT_NAME} Core)
    
    # Not required when CMAKE_AUTOUIC is ON
    #qt5_wrap_ui(CXX_QT_GENS ${CXX_UIFILES})
    
    target_sources(${PROJECT_NAME} PUBLIC ${CXX_QT_GENS})

endif ()

# ------------------------------ End of Qt related stuff ------------------------------
