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

    if (1)
        mk_install_Qt(${TARGET_NAME} ${TARGET_EXECUTABLE_FILE} INSTALLED_QT_PLUGINS SEARCH ${ARGS_SEARCH})
    endif ()

    # Fixup bundle

    set(BUNDLE_PLUGINS ${ARGS_PLUGINS} ${BUNDLE_QT_PLUGINS} CACHE INTERNAL "" FORCE)
    set(BUNDLE_FIXUP_QT_SEARCH_DIRS ${QT_MODULES_SRC_DIR})
    set(BUNDLE_FIXUP_SEARCH_DIRS ${ARGS_SEARCH} ${BUNDLE_FIXUP_QT_SEARCH_DIRS})

    #message(STATUS "Bundle plugins: ${BUNDLE_PLUGINS}")

    set(BU_CHMOD_BUNDLE_ITEMS TRUE)
    fixup_bundle(${TARGET_EXECUTABLE_FILE} "${BUNDLE_PLUGINS}" "${BUNDLE_FIXUP_SEARCH_DIRS}")

endfunction()
