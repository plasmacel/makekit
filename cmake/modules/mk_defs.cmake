#
#    MIT License
#
#    Copyright (c) 2018 Celestin de Villa
#
#    Permission is hereby granted, free of charge, to any person obtaining a copy
#    of this software and associated documentation files (the "Software"), to deal
#    in the Software without restriction, including without limitation the rights
#    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#    copies of the Software, and to permit persons to whom the Software is
#    furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in all
#    copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#    SOFTWARE.
#

#
# List of libraries with built-in support
#

set(MK_BUILTIN_LIBRARIES "") # Start with an empty list
set(MK_DEPLOY_FILES "")

#
# OS Platform Detection
#

if (CMAKE_HOST_WIN32) # True if the host system is running Windows, including Windows 64-bit and MSYS, but false on Cygwin.
	message(STATUS "MakeKit - Detected OS: Windows")
	set(MK_OS_WINDOWS 1)
elseif (CMAKE_HOST_UNIX) # True for UNIX and UNIX like operating systems, including APPLE operation systems and Cygwin.
	set(MK_OS_UNIX 1)
	if (CMAKE_HOST_APPLE) # True for Apple macOS operation systems.
		message(STATUS "MakeKit - Detected OS: macOS")
		set(MK_OS_MACOS 1)
	else ()
		message(STATUS "MakeKit - Detected OS: Unix/Linux")
		set(MK_OS_LINUX 1)
	endif ()
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
# File extensions
#

set(MK_ASM_SOURCE_SUFFIX *.asm *.s)

set(MK_C_SOURCE_SUFFIX *.c)
set(MK_C_HEADER_SUFFIX *.h)

set(MK_CXX_SOURCE_PATTERN *.c *.cc *.c++ *.cpp *.cxx)
set(MK_CXX_HEADER_PATTERN *.h *.hh *.h++ *.hpp *.hxx)
set(MK_CXX_INLINE_PATTERN *.inc *.inl *.ipp *.ixx *.tpp *.txx)
set(MK_CUDA_SOURCE_PATTERN *.cu)

if (MK_OS_WINDOWS)

	set(MK_CXX_RESOURCE_PATTERN *.rc) # Windows Resource (.rc)

	set(CMAKE_OBJECT_LIBRARY_PREFIX "")
	set(CMAKE_OBJECT_LIBRARY_PREFIX_C "")
	set(CMAKE_OBJECT_LIBRARY_PREFIX_CXX "")

	set(CMAKE_OBJECT_LIBRARY_SUFFIX .obj) # Object (.obj)
	set(CMAKE_OBJECT_LIBRARY_SUFFIX_C .obj) # Object (.obj)
	set(CMAKE_OBJECT_LIBRARY_SUFFIX_CXX .obj) # Object (.obj)

elseif (MK_OS_MACOS)

	set(CMAKE_OBJECT_LIBRARY_PREFIX "")
	set(CMAKE_OBJECT_LIBRARY_PREFIX_C "")
	set(CMAKE_OBJECT_LIBRARY_PREFIX_CXX "")

	set(CMAKE_OBJECT_LIBRARY_SUFFIX .o) # Object (.o)
	set(CMAKE_OBJECT_LIBRARY_SUFFIX_C .o) # Object (.o)
	set(CMAKE_OBJECT_LIBRARY_SUFFIX_CXX .o) # Object (.o)

else ()

	set(CMAKE_OBJECT_LIBRARY_PREFIX "")
	set(CMAKE_OBJECT_LIBRARY_PREFIX_C "")
	set(CMAKE_OBJECT_LIBRARY_PREFIX_CXX "")

	set(CMAKE_OBJECT_LIBRARY_SUFFIX .o) # Object (.o)
	set(CMAKE_OBJECT_LIBRARY_SUFFIX_C .o) # Object (.o)
	set(CMAKE_OBJECT_LIBRARY_SUFFIX_CXX .o) # Object (.o)

endif ()

# CMAKE_STATIC_LIBRARY_SUFFIX
#	Windows: .lib
#	macOS: .a
#	Linux: .a
# CMAKE_SHARED_LIBRARY_SUFFIX
#	Windows: .dll
#	macOS: .dylib
#	Linux: .so
# CMAKE_IMPORT_LIBRARY_SUFFIX
#	Windows: .lib
#	macOS: .dylib
#	Linux: .so
# CMAKE_OBJECT_LIBRARY_SUFFIX custom
#	Windows: .obj
#	macOS: .o
#	Linux: .o

#
# Find sources
#

if (TRUE) # MK_AUTO_REFRESH
	#cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
	set(MK_CONFIGURE_DEPENDS "CONFIGURE_DEPENDS")
else ()
	unset(MK_CONFIGURE_DEPENDS)
endif ()

#
# Functions and macros
#

# mk_message(MESSAGE_TYPE MESSAGE)
macro(mk_message MESSAGE_TYPE)
	message(${MESSAGE_TYPE} "MakeKit - ${ARGN}")
endmacro()
