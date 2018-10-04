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

#
# Configurations
#

set(MK_CONFIGS NONE DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)

# mk_add_config(<NAME> <INHERIT> C_FLAGS <...> CXX_FLAGS <...> LINKER_FLAGS <...> EXE_LINKER_FLAGS <...> SHARED_LINKER_FLAGS <...> STATIC_LINKER_FLAGS <...> [LIBRARY_POSTFIX <POSTFIX>])
# This function must be invoked at the top level of the project and before the first target_link_libraries() command invocation.
function(mk_add_config NAME INHERIT)

	# Parse arguments

	set(OPTION_KEYWORDS "")
	set(SINGLE_VALUE_KEYWORDS "LIBRARY_POSTFIX")
	set(MULTI_VALUE_KEYWORDS "C_FLAGS" "CXX_FLAGS" "LINKER_FLAGS" "EXE_LINKER_FLAGS" "SHARED_LINKER_FLAGS" "STATIC_LINKER_FLAGS")
	cmake_parse_arguments(PARSE_ARGV 0 "ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

	# Check against existing build types

	string(TOUPPER ${NAME} NAME_UPPERCASE)
	string(TOUPPER ${INHERIT} INHERIT_UPPERCASE)

	if (${NAME_UPPERCASE} IN_LIST ${MK_CONFIGS})
		mk_message(FATAL_ERROR "This is an already defined build type: ${NAME}")	
	else ()
		set(MK_CONFIGS ${MK_CONFIGS} ${NAME_UPPERCASE} PARENT_SCOPE)
	endif ()

	# Set cache variables

	set(CMAKE_C_FLAGS_${NAME_UPPERCASE} "${CMAKE_C_FLAGS_${INHERIT_UPPERCASE}} ${ARGS_C_FLAGS}"
		CACHE STRING "Flags used by the C compiler during ${NAME} builds"
		FORCE)

	set(CMAKE_CXX_FLAGS_${NAME_UPPERCASE} "${CMAKE_CXX_FLAGS_${INHERIT_UPPERCASE}} ${ARGS_CXX_FLAGS}"
		CACHE STRING "Flags used by the CXX compiler during ${NAME} builds"
		FORCE)

	set(CMAKE_EXE_LINKER_FLAGS_${NAME_UPPERCASE} "CMAKE_EXE_LINKER_FLAGS_${INHERIT_UPPERCASE} ${ARGS_LINKER_FLAGS} ${ARGS_EXE_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of executables during ${NAME} builds"
		FORCE)

	set(CMAKE_SHARED_LINKER_FLAGS_${NAME_UPPERCASE} "CMAKE_SHARED_LINKER_FLAGS_${INHERIT_UPPERCASE} ${ARGS_LINKER_FLAGS} ${ARGS_SHARED_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of shared libraries during ${NAME} builds"
		FORCE)

	set(CMAKE_STATIC_LINKER_FLAGS_${NAME_UPPERCASE} "CMAKE_STATIC_LINKER_FLAGS_${INHERIT_UPPERCASE} ${ARGS_LINKER_FLAGS} ${ARGS_STATIC_LINKER_FLAGS}"
		CACHE STRING "Flags used by the linker for the creation of static libraries during ${NAME} builds"
		FORCE)

	set(CMAKE_${NAME_UPPERCASE}_POSTFIX "${ARGS_LIBRARY_POSTFIX}"
		CACHE STRING ""
		FORCE)

	# Mark variables as advanced

	mark_as_advanced(
		CMAKE_CXX_FLAGS_${NAME_UPPERCASE}
		CMAKE_C_FLAGS_${NAME_UPPERCASE}
		CMAKE_EXE_LINKER_FLAGS_${NAME_UPPERCASE}
		CMAKE_SHARED_LINKER_FLAGS_${NAME_UPPERCASE}
		CMAKE_STATIC_LINKER_FLAGS_${NAME_UPPERCASE}
		CMAKE_${NAME_UPPERCASE}_POSTFIX)

	# Update the documentation string of CMAKE_BUILD_TYPE for GUIs

	set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}"
		CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel ${NAME}"
		FORCE)

	if (CMAKE_CONFIGURATION_TYPES) # This is defined for multi-configuration generators
		set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES} ${NAME}"
			CACHE STRING "List of configuration types for multi-configuration generators"
			FORCE)
	endif ()

	# If ${NAME} is a debug configuration, then add it to the list DEBUG_CONFIGURATIONS
	# This property must be set at the top level of the project and before the first target_link_libraries() command invocation.
	# https://cmake.org/cmake/help/v3.12/prop_gbl/DEBUG_CONFIGURATIONS.html

	if (${INHERIT_UPPERCASE} STREQUAL "DEBUG")
		set(DEBUG_CONFIGURATIONS "${DEBUG_CONFIGURATIONS} ${NAME}"
			CACHE STRING "List of debug configurations"
			FORCE)
	endif()

endfunction()

macro(mk_is_debug_config VAR)

	string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_UPPERCASE)
	
	if (${CMAKE_BUILD_TYPE_UPPERCASE} MATCHES "DEBUG" OR ${CMAKE_BUILD_TYPE_UPPERCASE} IN_LIST DEBUG_CONFIGURATIONS)
		set(${VAR} TRUE)
	else ()
		set(${VAR} FALSE)
	endif ()
	
endmacro()