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
# Include custom build types (compiler, linker and other flags)
#

include(CustomBuilds.cmake OPTIONAL)

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

include($ENV{MK_DIR}/cmake/modules/mk_config.cmake)
include($ENV{MK_DIR}/cmake/modules/mk_defs.cmake)
include($ENV{MK_DIR}/cmake/modules/mk_file.cmake)
include($ENV{MK_DIR}/cmake/modules/mk_install.cmake)
include($ENV{MK_DIR}/cmake/modules/mk_target.cmake)

include($ENV{MK_DIR}/cmake/modules/OpenCL.cmake)
include($ENV{MK_DIR}/cmake/modules/OpenGL.cmake)
include($ENV{MK_DIR}/cmake/modules/OpenMP.cmake)
include($ENV{MK_DIR}/cmake/modules/Qt.cmake)
include($ENV{MK_DIR}/cmake/modules/Vulkan.cmake)
