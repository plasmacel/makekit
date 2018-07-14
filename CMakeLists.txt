cmake_minimum_required(VERSION 3.10 FATAL_ERROR)

#include()

project(untitled)

# MakeKit Variables
#set(MAKEKIT_CLANG_CL 1)
#set(MAKEKIT_QT 1)
#set(MAKEKIT_OPENCL 1)
#set(MAKEKIT_OPENMP 1)
#set(MAKEKIT_CUDA 1)
#set(MAKEKIT_ASM 1)
#set(MAKEKIT_MODULE_MODE 0)

enable_language(C)
enable_language(CXX)

if (MAKEKIT_ASM)
    enable_language(ASM)
endif()

if (MAKEKIT_CUDA)
    enable_language(CUDA)
endif()

# Language Standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Compiler Flags
#set(CMAKE_CXX_FLAGS "/DWIN64 /D_WINDOWS /Wall /GR /EHsc" CACHE INTERNAL "")
#set (CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/CompilerOptions.cmake")

# OS Platform Detection
if (MSVC OR MSYS OR MINGW)
    set(MAKEKIT_OS_WINDOWS, 1)
elseif (UNIX)
    set(MAKEKIT_OS_UNIX, 1)
    if (APPLE)
        set(MAKEKIT_OS_MACOS, 1)
    else(APPLE)
        set(MAKEKIT_OS_LINUX, 1)
    endif(APPLE)
endif()

# Source and Executable
FILE(GLOB_RECURSE CXX_SOURCES "*.cc" "*.cpp" "*.cxx")
FILE(GLOB_RECURSE CXX_HEADERS "*.h" "*.hh" "*.hpp" ".hxx")
FILE(GLOB_RECURSE CXX_INLINES "*.inc" "*.inl" "*.ipp" "*.ixx")
if (MAKEKIT_OS_WINDOWS)
	FILE(GLOB_RECURSE CXX_OBJECTS "*.obj")
else (MAKEKIT_OS_WINDOWS)
	FILE(GLOB_RECURSE CXX_OBJECTS "*.o")
endif(MAKEKIT_OS_WINDOWS)

# ------------------------------ Qt related stuff ------------------------------
 if (MAKEKIT_QT)
    FILE(GLOB_RECURSE CXX_UIFILES "*.ui")
 
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTOUIC ON)
    set(CMAKE_AUTORCC ON)

    set(CMAKE_INCLUDE_CURRENT_DIR ON)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS}")

    if (MAKEKIT_CLANG_CL)
        set(Qt5_DIR "C:/Qt/5.10.0/msvc2017_64/lib/cmake/Qt5/")
    else (MAKEKIT_CLANG_CL)
        # Using MinGW Toolchain, CMake will find the Qt5 CMake configs
        #set(Qt5_DIR "C:/msys64/mingw64/lib/cmake/Qt5/")
    endif (MAKEKIT_CLANG_CL)

    find_package(Qt5 REQUIRED COMPONENTS core gui opengl widgets network)
    qt5_wrap_ui(CXX_QT_GENS ${CXX_UIFILES})
endif()

# ------------------------------ End of Qt related stuff ------------------------------

if (MAKEKIT_MODULE_MODE EQUALS 0)
	# Do nothing
elseif (MAKEKIT_MODULE_MODE LESS 4)
	if (MAKEKIT_MODULE_MODE EQUALS 1)
		set(MAKEKIT_MODULE_VISIBILITY INTERFACE)
	elseif (MAKEKIT_MODULE_MODE EQUALS 2)
		set(MAKEKIT_MODULE_VISIBILITY PRIVATE)
	elseif (MAKEKIT_MODULE_MODE EQUALS 3)
		set(MAKEKIT_MODULE_VISIBILITY PUBLIC)
	endif()
	
	add_library(${PROJECT_NAME} ${MAKEKIT_MODULE_VISIBILITY} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
else()
	add_executable(${PROJECT_NAME} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES} ${CXX_OBJECTS} ${CXX_UIFILES})
endif()

# Linked libraries

# OpenCL
if (MAKEKIT_OPENCL)
    find_package(OpenCL REQUIRED)
    target_link_libraries(${PROJECT_NAME} OpenCL::OpenCL)
endif()

# OpenMP
if (MAKEKIT_OPENMP)
	set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp")
	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
	target_link_libraries(${PROJECT_NAME} "C:/Program Files (x86)/LLVM/lib/libomp.lib")
    #find_package(OpenMP REQUIRED)
    #if (OPENMP_FOUND)
	#	set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
	#	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	#	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${OpenMP_SHARED_LINKER_FLAGS}")
	#	set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
    #endif()
endif ()

if (MAKEKIT_QT)
    target_link_libraries(${PROJECT_NAME} Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network)
endif (MAKEKIT_QT)

# Custom libraries

#target_link_libraries(${PROJECT_NAME} mylib.lib)

# ------------------------------ Qt related stuff ------------------------------

if (MAKEKIT_QT)
	
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTOUIC ON)
    set(CMAKE_AUTORCC ON)
    set(CMAKE_INCLUDE_CURRENT_DIR ON)

    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    
    #set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS}")

    # Use CMAKE_PREFIX_PATH
    #set(CMAKE_PREFIX_PATH "C:/Qt/5.10.0/msvc2017_64/lib/cmake/Qt5/")
    #set(CMAKE_PREFIX_PATH "C:/msys64/mingw64/lib/cmake/Qt5/")

    # Use Qt5_DIR
    if (MAKEKIT_CLANG_CL)
        set(Qt5_DIR "C:/Qt/5.10.0/msvc2017_64/lib/cmake/Qt5/")
    else (MAKEKIT_CLANG_CL)
        # Using MinGW Toolchain, CMake will find the Qt5 CMake configs
        #set(Qt5_DIR "C:/msys64/mingw64/lib/cmake/Qt5/")
    endif (MAKEKIT_CLANG_CL)

    find_package(Qt5 REQUIRED COMPONENTS Core)
    target_link_libraries(${PROJECT_NAME} Qt5::Core)
    #target_link_libraries(${PROJECT_NAME} ${Qt5Core_LIBRARIES} Qt5::Core ${MYPROJECT_LIBRARIES})
    #or
    #find_package(Qt5Core REQUIRED)
    #qt5_use_modules(${PROJECT_NAME} Core)
    
    qt5_wrap_ui(CXX_QT_GENS ${CXX_UIFILES})
    target_sources(${PROJECT_NAME} PUBLIC ${CXX_QT_GENS})

endif(MAKEKIT_QT)

# ------------------------------ End of Qt related stuff ------------------------------

