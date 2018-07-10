cmake_minimum_required(VERSION 3.10)
project(untitled)

# MakeKit Variables
#set(MAKEKIT_CLANG_CL 0)
#set(MAKEKIT_QT 1)

# Language Standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Compiler Flags
#set(CMAKE_CXX_FLAGS "/DWIN64 /D_WINDOWS /Wall /GR /EHsc" CACHE INTERNAL "")
#set (CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/CompilerOptions.cmake")

# Source and Executable
#add_executable(${PROJECT_NAME} main.cpp)
set(SOURCE main.cpp)
add_executable(${PROJECT_NAME} ${SOURCE})

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
