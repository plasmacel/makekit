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

include(BundleUtilities)
include($ENV{MK_DIR}/cmake/modules/InstallQt.cmake)

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

#
# Install operations
#

# mk_get_target_dependencies(<VAR> <TARGET_BINARY_FILE> [NOSYSTEM = TRUE] [RECURSE = FALSE] [SEARCH <...>] [RPATHS <...>])
# <SEARCH_DIRS> is a list of paths where libraries might be found: these paths are searched first when a target without any path info is given.
# Then standard system locations are also searched: PATH, Framework locations, /usr/lib…
macro(mk_get_dependencies VAR TARGET_BINARY_FILE)

	set(OPTION_KEYWORDS "NOSYSTEM" "RECURSE")
	set(SINGLE_VALUE_KEYWORDS "")
	set(MULTI_VALUE_KEYWORDS "RPATHS" "SEARCH")
	cmake_parse_arguments("ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

	if (${ARGS_NOSYSTEM} STREQUAL "")
		set(ARGS_NOSYSTEM 1)
	endif ()

	if (${ARGS_RECURSE} STREQUAL "")
		set(ARGS_RECURSE 0)
	endif ()

	get_filename_component(TARGET_BINARY_DIR "${TARGET_BINARY_FILE}" DIRECTORY)

	get_prerequisites("${TARGET_BINARY_FILE}" "${VAR}" "${ARGS_NOSYSTEM}" "${ARGS_RECURSE}" "${TARGET_BINARY_DIR}" "${ARGS_SEARCH}" "${ARGS_RPATHS}")

endmacro()

function(mk_install_file TARGET_NAME PLUGIN_FILE)
    file(COPY ${PLUGIN_FILE} DESTINATION "${PLUGINS_DIR}")
endfunction()

# mk_install(<TARGET_NAME> [PLUGINS <...>] [SEARCH <...>])
function(mk_install TARGET_NAME TARGET_EXECUTABLE_FILE)

    set(OPTION_KEYWORDS "QT")
    set(SINGLE_VALUE_KEYWORDS "")
    set(MULTI_VALUE_KEYWORDS "PLUGINS" "SEARCH")
    cmake_parse_arguments(PARSE_ARGV 0 "ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

	if (WIN32)
		set(TARGET_EXECUTABLE_FILE ${CMAKE_INSTALL_PREFIX}/${TARGET_NAME}.exe)
	elseif (APPLE)
		set(TARGET_EXECUTABLE_FILE ${CMAKE_INSTALL_PREFIX}/${TARGET_NAME}.app/Contents/MacOS/${TARGET_NAME})
	elseif (UNIX)
		set(TARGET_EXECUTABLE_FILE ${CMAKE_INSTALL_PREFIX}/${TARGET_NAME})
	endif ()

	# CMAKE_EXECUTABLE_SUFFIX
	# CMAKE_<CONFIG>_POSTFIX

	set(IS_DEBUG 0)

    if (1)
        mk_install_Qt(${TARGET_NAME} ${TARGET_EXECUTABLE_FILE} ${IS_DEBUG} SEARCH ${ARGS_SEARCH})
    endif ()

    # Fixup bundle

    set(BUNDLE_PLUGINS ${ARGS_PLUGINS} ${BUNDLE_QT_PLUGINS} CACHE INTERNAL "" FORCE)
    set(BUNDLE_FIXUP_QT_SEARCH_DIRS ${QT_MODULES_SRC_DIR})
    set(BUNDLE_FIXUP_SEARCH_DIRS ${ARGS_SEARCH} ${BUNDLE_FIXUP_QT_SEARCH_DIRS})

    #message(STATUS "Bundle plugins: ${BUNDLE_PLUGINS}")

    set(BU_CHMOD_BUNDLE_ITEMS TRUE)
    fixup_bundle(${TARGET_EXECUTABLE_FILE} "${BUNDLE_PLUGINS}" "${BUNDLE_FIXUP_SEARCH_DIRS}")

endfunction()
