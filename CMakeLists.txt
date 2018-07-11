cmake_minimum_required(VERSION 3.10)
project(untitled)

# MakeKit Variables
#set(MAKEKIT_CLANG_CL 1)
#set(MAKEKIT_QT 1)
#set(MAKEKIT_OPENCL 1)
set(MAKEKIT_OPENMP 1)
#set(MAKEKIT_CUDA 1)
#set(MAKEKIT_ASM 1)

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

# OpenMP Compiler Flag(s)
if (MAKEKIT_OPENMP)
	set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
    #find_package(OpenMP REQUIRED)
    #if (OPENMP_FOUND)
    #    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    #    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
    #endif()
endif (MAKEKIT_OPENMP)

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
#add_executable(${PROJECT_NAME} main.cpp)
FILE(GLOB_RECURSE CXX_SOURCES "*.cc" "*.cpp" "*.cxx")
FILE(GLOB_RECURSE CXX_HEADERS "*.h" "*.hh" "*.hpp" ".hxx")
FILE(GLOB_RECURSE CXX_INLINES "*.inc" "*.inl" "*.ipp")
add_executable(${PROJECT_NAME} ${CXX_HEADERS} ${CXX_INLINES} ${CXX_SOURCES})

# Linked libraries
# Link OpenCL
if (MAKEKIT_OPENCL)
    find_package(OpenCL REQUIRED)
    target_link_libraries(${PROJECT_NAME} OpenCL::OpenCL)
endif()
#target_link_libraries(${PROJECT_NAME} mylib.lib)

# ------------------------------ Qt related stuff ------------------------------

if (MAKEKIT_QT)

    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTOUIC ON)
    set(CMAKE_AUTORCC ON)

    #set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
    #set(CMAKE_INCLUDE_CURRENT_DIR ON)
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

endif(MAKEKIT_QT)

# ------------------------------ End of Qt related stuff ------------------------------
