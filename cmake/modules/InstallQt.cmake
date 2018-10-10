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
# Qt
# Precondition: The MK_QT_DIR environmental variable must be set to a valid Qt path.
# http://doc.qt.io/qt-5/qtmodules.html
# http://doc.qt.io/qt-5/cmake-manual.html#imported-targets
#

include(BundleUtilities)
include(GetPrerequisites)
include($ENV{MK_DIR}/cmake/modules/mk_config.cmake)

cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

macro(mk_is_Qt_module VAR LIBRARY_NAME)
	if (${LIBRARY_NAME} MATCHES "^(lib)?Qt.*")
		set(${VAR} TRUE)
	else()
		set(${VAR} FALSE)
	endif ()
endmacro()

function(mk_install_Qt_conf)

    set(CONF ${ARGV2})

    message(STATUS "Install Qt conf file: ${BUNDLE_DIR}/${BUNDLE_CONF_DIR}/qt.conf")

    if (NOT "${CONF}" STREQUAL "" AND EXISTS "${CONF}")
        file(COPY ${CONF} DESTINATION ${BUNDLE_DIR}/${BUNDLE_CONF_DIR})
    else () # Write default qt.conf file
        if (WIN32)
            set(CONF "[Paths]\nPlugins = ${BUNDLE_PLUGINS_DIR}\nImports = qml\nQml2Imports = qml")
        elseif(APPLE)
            set(CONF "[Paths]\nPlugins = ${BUNDLE_PLUGINS_DIR}\nImports = Resources/qml\nQml2Imports = Resources/qml")
        elseif(UNIX)
            set(CONF "[Paths]\nPlugins = ${BUNDLE_PLUGINS_DIR}\nImports = qml\nQml2Imports = qml\nPrefix = ../")
        endif()

        file(WRITE ${BUNDLE_DIR}/${BUNDLE_CONF_DIR}/qt.conf "${CONF}")
    endif ()

endfunction()

macro(mk_append_unique LIST VALUE)

    if (NOT ${VALUE} IN_LIST ${LIST})
        set(${LIST} ${LIST} ${VALUE} ${ARGV3})
    endif ()

endmacro()

function(mk_install_Qt_plugin_module TARGET_EXECUTABLE_FILE PLUGIN_MODULE IS_DEBUG)

    #get_bundle_and_exeutable(<app> <bundle_var> <executable_var> TARGET_IS_VALID)

    # Collect all libraries in the module directory
	#message(STATUS "Globbing Qt plugins as ${QT_PLUGIN_MODULES_SRC_DIR}/${PLUGIN_MODULE}/*${CMAKE_SHARED_LIBRARY_SUFFIX}")
    file(GLOB ${PLUGIN_MODULE}_FILES FOLLOW_SYMLINKS "${QT_PLUGIN_MODULES_SRC_DIR}/${PLUGIN_MODULE}/*${CMAKE_SHARED_LIBRARY_SUFFIX}")

    # Filter plugin libraries

    # Include shared (runtime) library files only
    list(FILTER ${PLUGIN_MODULE}_FILES INCLUDE REGEX "^.*\\${CMAKE_SHARED_LIBRARY_SUFFIX}$")

	if (${IS_DEBUG})
        list(TRANSFORM ${PLUGIN_MODULE}_FILES REPLACE "(^.*)${QT_RELEASE_SUFFIX}\\${CMAKE_SHARED_LIBRARY_SUFFIX}$" "\\1${QT_DEBUG_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    else ()
        list(TRANSFORM ${PLUGIN_MODULE}_FILES REPLACE "(^.*)${QT_DEBUG_SUFFIX}\\${CMAKE_SHARED_LIBRARY_SUFFIX}$" "\\1${QT_RELEASE_SUFFIX}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    endif ()
	
	list(REMOVE_DUPLICATES ${PLUGIN_MODULE}_FILES)

	# Skip if no files to process

    if ("${${PLUGIN_MODULE}_FILES}" STREQUAL "")
        return()
    endif ()

    message(STATUS "${PLUGIN_MODULE}: ${${PLUGIN_MODULE}_FILES}")

    # Get and accumulate dependencies of plugin files

    foreach(PLUGIN IN LISTS ${PLUGIN_MODULE}_FILES)

		if (EXISTS ${PLUGIN})

			get_prerequisites(${PLUGIN} PLUGIN_DEPENDENCIES 1 0 "" ${QT_MODULES_SRC_DIR})

			#message(STATUS "Dependencies of ${PLUGIN}: ${PLUGIN_DEPENDENCIES}")

			foreach(PLUGIN_DEPENDENCY IN LISTS PLUGIN_DEPENDENCIES)

				get_item_key(${PLUGIN_DEPENDENCY} PLUGIN_DEPENDENCY_KEY)

				# Resolve item (gp_resolve_item) and set key values
				#gp_resolve_item(${PLUGIN} ${PLUGIN_DEPENDENCY} "" ${QT_MODULES_SRC_DIR} RESOLVED_PLUGIN_DEPENDENCY)
				get_filename_component(TARGET_EXECUTABLE_DIR "${TARGET_EXECUTABLE_FILE}" DIRECTORY)
				set_bundle_key_values(MODULE_DEPENDENCY_KEYS ${PLUGIN_DEPENDENCY} ${PLUGIN_DEPENDENCY} ${TARGET_EXECUTABLE_DIR} ${QT_MODULES_SRC_DIR} 1)

			endforeach()

			# Install plugin module files

			get_filename_component(PLUGIN_NAME ${PLUGIN} NAME)
			copy_resolved_item_into_bundle(${PLUGIN} "${BUNDLE_DIR}/${BUNDLE_PLUGINS_DIR}/${PLUGIN_MODULE}/${PLUGIN_NAME}")
			#file(COPY ${PLUGIN} DESTINATION "${BUNDLE_DIR}/${BUNDLE_PLUGINS_DIR}/${PLUGIN_MODULE}/.")

		endif ()

    endforeach()

    # Copy accumulated dependecies of the plugin module

    foreach(KEY IN LISTS MODULE_DEPENDENCY_KEYS)

	mk_is_Qt_module(IS_QT_MODULE ${KEY})

        if (${IS_QT_MODULE} AND NOT ${KEY} IN_LIST BUNDLE_QT_MODULES)
        set(BUNDLE_QT_MODULES ${BUNDLE_QT_MODULES} ${KEY} CACHE INTERNAL "" FORCE)
        endif()

    endforeach()

    if (NOT ${PLUGIN_MODULE} IN_LIST BUNDLE_QT_PLUGIN_MODULES)
        set(BUNDLE_QT_PLUGIN_MODULES ${BUNDLE_QT_PLUGIN_MODULES} ${PLUGIN_MODULE} CACHE INTERNAL "" FORCE)
    endif ()

    file(GLOB_RECURSE EMBEDDED_PLUGINS "${BUNDLE_DIR}/${BUNDLE_PLUGINS_DIR}/${PLUGIN_MODULE}/*${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(BUNDLE_QT_PLUGINS ${BUNDLE_QT_PLUGINS} ${EMBEDDED_PLUGINS} CACHE INTERNAL "" FORCE)

endfunction()

function(mk_install_Qt_plugins TARGET_EXECUTABLE_FILES IS_DEBUG)

	set(OPTION_KEYWORDS "")
    set(SINGLE_VALUE_KEYWORDS "")
    set(MULTI_VALUE_KEYWORDS "SEARCH")
    cmake_parse_arguments(PARSE_ARGV 0 "ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

    set(BUNDLE_QT_MODULES "" CACHE INTERNAL "" FORCE)
    set(BUNDLE_QT_PLUGINS "" CACHE INTERNAL "" FORCE)
    set(BUNDLE_QT_PLUGIN_MODULES "" CACHE INTERNAL "" FORCE)

	math(EXPR INDEX 0)

	foreach (TARGET_EXECUTABLE_FILE IN LISTS TARGET_EXECUTABLE_FILES)

		# Get list of unresolved prerequisites of the target executable

		get_filename_component(TARGET_EXECUTABLE_DIR ${TARGET_EXECUTABLE_FILE} DIRECTORY)

		get_prerequisites(${TARGET_EXECUTABLE_FILE} TARGET_DEPENDENCIES 1 0 "${TARGET_EXECUTABLE_DIR}" "${ARGS_SEARCH};${QT_MODULES_SRC_DIR}")

		# Collect Qt prerequisites as list of module names

		foreach (TARGET_DEPENDENCY IN LISTS TARGET_DEPENDENCIES)
			get_filename_component(LIBRARY_NAME ${TARGET_DEPENDENCY} NAME_WE)
				
			mk_is_Qt_module(IS_QT_MODULE ${LIBRARY_NAME})

			if (${IS_QT_MODULE} AND NOT ${LIBRARY_NAME} IN_LIST BUNDLE_QT_MODULES)
				set(BUNDLE_QT_MODULES ${BUNDLE_QT_MODULES} ${LIBRARY_NAME} CACHE INTERNAL "" FORCE)
			endif ()
		endforeach ()

		message(STATUS "Install Qt plugins...")

		# Handle Qt prerequisites

		list(LENGTH BUNDLE_QT_MODULES BUNDLE_QT_MODULES_LENGTH)

		while (INDEX LESS BUNDLE_QT_MODULES_LENGTH)

			list(GET BUNDLE_QT_MODULES ${INDEX} LIBRARY_NAME)

			#message(STATUS "Prerequisite plugins of ${LIBRARY_NAME}...")

			set(PLUGIN_SRC_DIRS "")

			if (${LIBRARY_NAME} MATCHES "Qt5?Core")
				list(APPEND PLUGIN_SRC_DIRS platforms)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Declarative")
				list(APPEND PLUGIN_SRC_DIRS qml1tooling)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?GamePad")
				list(APPEND PLUGIN_SRC_DIRS gamepads)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Gui")
				list(APPEND PLUGIN_SRC_DIRS accessible iconengines imageformats platforms platforminputcontexts)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Location")
				list(APPEND PLUGIN_SRC_DIRS geoservices)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Multimedia")
				list(APPEND PLUGIN_SRC_DIRS audio mediaservice playlistformats)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Network")
				list(APPEND PLUGIN_SRC_DIRS bearer)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Positioning")
				list(APPEND PLUGIN_SRC_DIRS position)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?PrintSupport")
				list(APPEND PLUGIN_SRC_DIRS printsupport)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Quick")
				list(APPEND PLUGIN_SRC_DIRS qmltooling scenegraph)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?QmlTooling")
				list(APPEND PLUGIN_SRC_DIRS scenegraph)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Sensors")
				list(APPEND PLUGIN_SRC_DIRS sensors sensorgestures)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?SerialBus")
				list(APPEND PLUGIN_SRC_DIRS canbus)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Sql")
				list(APPEND PLUGIN_SRC_DIRS sqldrivers)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?TextToSpeech")
				list(APPEND PLUGIN_SRC_DIRS texttospeech)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?WebEngine")
				list(APPEND PLUGIN_SRC_DIRS qtwebengine)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?WebEngineCore")
				list(APPEND PLUGIN_SRC_DIRS qtwebengine)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?WebEngineWidgets")
				list(APPEND PLUGIN_SRC_DIRS qtwebengine)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?WebView")
				list(APPEND PLUGIN_SRC_DIRS webview)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?Widgets")
				list(APPEND PLUGIN_SRC_DIRS styles)
			elseif (${LIBRARY_NAME} MATCHES "Qt5?3DRenderer")
				list(APPEND PLUGIN_SRC_DIRS geometryloaders renderplugins sceneparsers)
			endif ()

			# Install required Qt plugins for the current module
			foreach (PLUGIN_SRC_DIR IN LISTS PLUGIN_SRC_DIRS)

				if (NOT ${PLUGIN_SRC_DIR} IN_LIST BUNDLE_QT_PLUGIN_MODULES)
					mk_install_Qt_plugin_module(${TARGET_EXECUTABLE_FILE} ${PLUGIN_SRC_DIR} ${IS_DEBUG})
				endif ()

			endforeach ()

			# Update loop condition variables

			list(LENGTH BUNDLE_QT_MODULES BUNDLE_QT_MODULES_LENGTH)
			math(EXPR INDEX ${INDEX}+1)

		endwhile()

	endforeach ()

    # Print install info

    list(SORT BUNDLE_QT_PLUGIN_MODULES)
    list(SORT BUNDLE_QT_MODULES)

    message(STATUS "Installed Qt modules: ${BUNDLE_QT_MODULES}")
    message(STATUS "Installed Qt plugin modules: ${BUNDLE_QT_PLUGIN_MODULES}")

endfunction()

function(mk_install_Qt_translations)

endfunction()

function(mk_install_Qt TARGET_NAME TARGET_EXECUTABLE_FILE IS_DEBUG)

	set(OPTION_KEYWORDS "")
    set(SINGLE_VALUE_KEYWORDS "")
    set(MULTI_VALUE_KEYWORDS "SEARCH")
    cmake_parse_arguments(PARSE_ARGV 0 "ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}")

	if (WIN32)
		set(CMAKE_SHARED_LIBRARY_SUFFIX .dll CACHE INTERNAL "" FORCE)
		set(BUNDLE_DIR "${CMAKE_INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)
		set(BUNDLE_CONF_DIR "." CACHE INTERNAL "" FORCE)
		set(BUNDLE_PLUGINS_DIR "." CACHE INTERNAL "" FORCE)
		set(QT_DEBUG_SUFFIX "d" CACHE INTERNAL "" FORCE)
		set(QT_RELEASE_SUFFIX "" CACHE INTERNAL "" FORCE)
		set(QT_MODULES_SRC_DIR "$ENV{MK_QT_DIR}/bin" CACHE INTERNAL "" FORCE)
		set(QT_PLUGIN_MODULES_SRC_DIR "$ENV{MK_QT_DIR}/plugins" CACHE INTERNAL "" FORCE)
	elseif (APPLE)
		set(CMAKE_SHARED_LIBRARY_SUFFIX .dylib CACHE INTERNAL "" FORCE)
		set(BUNDLE_DIR "${CMAKE_INSTALL_PREFIX}/${TARGET_NAME}.app/Contents" CACHE INTERNAL "" FORCE)
		set(BUNDLE_CONF_DIR "Resources" CACHE INTERNAL "" FORCE)
		set(BUNDLE_PLUGINS_DIR "PlugIns" CACHE INTERNAL "" FORCE)
		set(QT_DEBUG_SUFFIX "_debug" CACHE INTERNAL "" FORCE)
		set(QT_RELEASE_SUFFIX "" CACHE INTERNAL "" FORCE)
		set(QT_MODULES_SRC_DIR "$ENV{MK_QT_DIR}/lib" CACHE INTERNAL "" FORCE)
		set(QT_PLUGIN_MODULES_SRC_DIR "$ENV{MK_QT_DIR}/plugins" CACHE INTERNAL "" FORCE)
	elseif (UNIX)
		set(CMAKE_SHARED_LIBRARY_SUFFIX .so CACHE INTERNAL "" FORCE)
		set(BUNDLE_DIR "${CMAKE_INSTALL_PREFIX}" CACHE INTERNAL "" FORCE)
		set(BUNDLE_CONF_DIR "." CACHE INTERNAL "" FORCE)
		set(BUNDLE_PLUGINS_DIR "plugins" CACHE INTERNAL "" FORCE)
		set(QT_DEBUG_SUFFIX "_debug" CACHE INTERNAL "" FORCE)
		set(QT_RELEASE_SUFFIX "" CACHE INTERNAL "" FORCE)
		set(QT_MODULES_SRC_DIR "$ENV{MK_QT_DIR}/lib" CACHE INTERNAL "" FORCE)
		set(QT_PLUGIN_MODULES_SRC_DIR "$ENV{MK_QT_DIR}/plugins" CACHE INTERNAL "" FORCE)
	else ()
		message(FATAL_ERROR "Unsupported OS")
	endif ()

	if (NOT EXISTS ${QT_MODULES_SRC_DIR})
		message(FATAL_ERROR "Qt library modules directory cannot be found: ${QT_MODULES_SRC_DIR}")
		return()
	endif ()

	if (NOT EXISTS ${QT_PLUGIN_MODULES_SRC_DIR})
		message(FATAL_ERROR "Qt plugin modules directory cannot be found: ${QT_PLUGIN_MODULES_SRC_DIR}")
		return()
	endif ()

	#get_bundle_all_executables(${BUNDLE} <exes_var>)
	#get_bundle_main_executable(${BUNDLE})

    mk_install_Qt_conf()
    mk_install_Qt_plugins(${TARGET_EXECUTABLE_FILE} ${IS_DEBUG} SEARCH ${ARGS_SEARCH})
	mk_install_Qt_translations()

endfunction()
