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
include(ProcessorCount)

#
# Qt
# Precondition: The MK_QT_DIR environmental variable must be set to a valid Qt path.
# http://doc.qt.io/qt-5/qtmodules.html
# http://doc.qt.io/qt-5/cmake-manual.html#imported-targets
#

list(APPEND MK_BUILTIN_LIBRARIES Qt)
set(MK_QT_QMLDIR)

macro(mk_source_autogen_Qt)

	foreach(SOURCE_FILE IN ITEMS ${ARGN})
		set_property(SOURCE ${SOURCE_FILE} PROPERTY SKIP_AUTOGEN OFF)
	endforeach()

endmacro()

macro(mk_target_link_Qt TARGET_NAME)

	set(OPTION_KEYWORDS "AUTOMOC" "AUTORCC" "AUTOUIC" "AUTOSKIP")
    	set(SINGLE_VALUE_KEYWORDS "QMLDIR" "THREADS")
   	set(MULTI_VALUE_KEYWORDS "MODULES")
	cmake_parse_arguments("ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

	set(MK_QT_QMLDIR ${ARGS_QMLDIR})

	# Find Qt5

	set(Qt5_DIR $ENV{MK_QT_DIR}/lib/cmake/Qt5)
	find_package(Qt5 COMPONENTS ${ARGS_MODULES} REQUIRED)

	if (NOT Qt5_FOUND)
		mk_message(FATAL_ERROR "Qt5 libraries cannot be found!")
		return()
	endif ()

	mk_message(STATUS "Found Qt5 version ${Qt5_VERSION}")

	# Include current directory

	set(CMAKE_INCLUDE_CURRENT_DIR ON)

	# Setting Qt related target properties (AUTOMOC, AUTORCC, AUTOUIC)
	#
	# https://cmake.org/cmake/help/latest/prop_tgt/AUTOMOC.html
	# https://cmake.org/cmake/help/latest/manual/cmake-qt.7.html#automoc
	#
	# https://cmake.org/cmake/help/latest/prop_tgt/AUTORCC.html
	# https://cmake.org/cmake/help/latest/manual/cmake-qt.7.html#autorcc
	#
	# https://cmake.org/cmake/help/latest/prop_tgt/AUTOUIC.html
	# https://cmake.org/cmake/help/latest/manual/cmake-qt.7.html#autouic
	#
	# These properties are automatically set if the following variables are set before adding the target
	# set(CMAKE_AUTOMOC ON)
	# set(CMAKE_AUTORCC ON)
	# set(CMAKE_AUTOUIC ON)

	if (${ARGS_THREADS}) # Use specified number of parallel CPU threads
		set(THREADS ${ARGS_THREADS})
	else() # Use all available parallel CPU threads
		ProcessorCount(THREADS)
	endif()
	
	set_target_properties(${TARGET_NAME} PROPERTIES AUTOGEN_PARALLEL ${THREADS}) # Number of parallel CPU threads used for moc, rcc, uic
	#set_target_properties(${TARGET_NAME} PROPERTIES AUTOMOC_MACRO_NAMES Q_SOURCE) # Macro for finding Qt C++ source files
	set_target_properties(${TARGET_NAME} PROPERTIES AUTOMOC ${ARGS_AUTOMOC}) # Automatically execute moc on required C++ files
	set_target_properties(${TARGET_NAME} PROPERTIES AUTORCC ${ARGS_AUTORCC}) # Automatically execute rcc on .qrc files
	set_target_properties(${TARGET_NAME} PROPERTIES AUTOUIC ${ARGS_AUTOUIC}) # Automatically execute uic on .ui files

	target_compile_definitions(${TARGET_NAME} PRIVATE Q_SOURCE)

	# Skip AUTOGEN of sources by default

	if (${ARGS_AUTOSKIP})

		message(STATUS "AUTOSKIP AUTOGEN")

		set(TARGET_SOURCES "")
		get_property(TARGET_SOURCES TARGET ${TARGET_NAME} PROPERTY SOURCES)

		foreach(TARGET_SOURCE IN ITEMS ${TARGET_SOURCES})
			set_property(SOURCE ${TARGET_SOURCE} PROPERTY SKIP_AUTOGEN ON)
		endforeach()

	endif()

	# Add Qt source files to the target (they are being appended to its SOURCE property)

	file(GLOB_RECURSE CXX_QMFILES ${MK_CONFIGURE_DEPENDS} *.qm)

	if (${ARGS_AUTORCC})
		file(GLOB_RECURSE CXX_QRCFILES ${MK_CONFIGURE_DEPENDS} *.qrc)
	endif()

	if (${ARGS_AUTOUIC})
		file(GLOB_RECURSE CXX_UIFILES ${MK_CONFIGURE_DEPENDS} *.ui)
	endif()

	target_sources(${TARGET_NAME} PRIVATE ${CXX_QMFILES} PRIVATE ${CXX_QRCFILES} PRIVATE ${CXX_UIFILES})

	# This is not required, since target_link_libraries does this automatically
	#compile_options(${TARGET_NAME} ${Qt5Core_EXECUTABLE_COMPILE_FLAGS})

	# Link and deploy required Qt libraries

	set(ALL_QT_MODULES Bluetooth Charts Concurrent Core DataVisualization DBus Designer Gamepad Gui Help LinguistTools Location MacExtras Multimedia MultimediaWidgets Network NetworkAuth Nfc OpenGL OpenGLExtensions Positioning PositioningQuick PrintSupport Purchasing Qml Quick QuickCompiler QuickControls2 QuickTest QuickWidgets RemoteObjects RepParser Script ScriptTools Scxml Sensors SerialBus SerialPort Sql Svg Test TextToSpeech UiPlugin UiTools WebChannel WebEngine WebEngineCore WebEngineWidgets WebSockets WebView Widgets Xml XmlPatterns 3DAnimation 3DCore 3DExtras 3DInput 3DLogic 3DQuick 3DQuickAnimation 3DQuickExtras 3DQuickInput 3DQuickRender 3DQuickScene2D 3DRender)

	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (${TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")
		set(LINK_SCOPE INTERFACE)
	else ()
		unset(LINK_SCOPE)
	endif ()

	foreach (QT_MODULE IN ITEMS ${ARGS_MODULES})
		if (NOT ${QT_MODULE} IN_LIST ALL_QT_MODULES)
			mk_message(SEND_ERROR "Skipping invalid Qt module: ${QT_MODULE}")
			continue()
		endif ()
		
		target_link_libraries(${TARGET_NAME} ${LINK_SCOPE} Qt5::${QT_MODULE}) # Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network
		#mk_target_deploy_libraries(${TARGET_NAME} Qt5::${QT_MODULE})
	endforeach ()

	unset(LINK_SCOPE)
	unset(TARGET_SOURCES)

endmacro()

function(mk_target_deploy_Qt TARGET_NAME)

	#set(OPTION_KEYWORDS "")
	#set(SINGLE_VALUE_KEYWORDS "QMLDIR")
	#set(MULTI_VALUE_KEYWORDS "")
	#cmake_parse_arguments("ARGS" "${OPTION_KEYWORDS}" "${SINGLE_VALUE_KEYWORDS}" "${MULTI_VALUE_KEYWORDS}" ${ARGN})

	if (CMAKE_CROSSCOMPILING)
		mk_message(SEND_ERROR "The Qt deployment tool supports only the native target platform!")
		return()
	endif ()

	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (NOT TARGET_TYPE STREQUAL "EXECUTABLE")
		mk_message(SEND_ERROR "mk_target_deploy_Qt(...) requires an EXECUTABLE target!")
		return()
	endif ()
	
	mk_message(STATUS "Deploy Qt")
	if ("${MK_QT_QMLDIR}" STREQUAL "")
		mk_message(STATUS "Qt not using QML")
	else ()
		mk_message(STATUS "Qt qmldir: ${MK_QT_QMLDIR}")
	endif ()

	if (MK_OS_WINDOWS)

		if (MK_FULL_DEPLOY)
			set_target_properties(${TARGET_NAME} PROPERTIES WIN32_EXECUTABLE TRUE)
			set(QT_DEPLOY_OPTIONS --force)
		endif ()

		if ("${MK_QT_QMLDIR}" STREQUAL "")
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/windeployqt ${QT_DEPLOY_OPTIONS} $<TARGET_FILE:${TARGET_NAME}>)
		else ()
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/windeployqt ${QT_DEPLOY_OPTIONS} --qmldir ${MK_QT_QMLDIR} $<TARGET_FILE:${TARGET_NAME}>)
		endif ()

	elseif (MK_OS_MACOS)
		
		if (MK_FULL_DEPLOY)
			set_target_properties(${TARGET_NAME} PROPERTIES MACOSX_BUNDLE TRUE)
			set(QT_DEPLOY_OPTIONS -always-overwrite)
		else ()
			get_target_property(TARGET_IS_BUNDLE ${TARGET_NAME} MACOSX_BUNDLE)

			if (NOT TARGET_IS_BUNDLE)
				mk_message(SEND_ERROR "The Qt deployment tool on macOS requires an application bundle target")
				return()
			endif ()
		endif ()

		# macdeployqt strictly requires a macOS application bundle
		if ("${MK_QT_QMLDIR}" STREQUAL "")
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/macdeployqt $<TARGET_BUNDLE_DIR:${TARGET_NAME}> ${QT_DEPLOY_OPTIONS})
		else ()
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/macdeployqt $<TARGET_BUNDLE_DIR:${TARGET_NAME}> ${QT_DEPLOY_OPTIONS} -qmldir=${MK_QT_QMLDIR})
		endif ()

	elseif (MK_OS_LINUX)

		if (MK_FULL_DEPLOY)
			set(QT_DEPLOY_OPTIONS -always-overwrite)
		endif ()

		if ("${MK_QT_QMLDIR}" STREQUAL "")
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/linuxdeployqt $<TARGET_FILE:${TARGET_NAME}> -qmake=$ENV{MK_QT_DIR}/bin/qmake ${QT_DEPLOY_OPTIONS})
		else ()
			add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/linuxdeployqt $<TARGET_FILE:${TARGET_NAME}> -qmake=$ENV{MK_QT_DIR}/bin/qmake ${QT_DEPLOY_OPTIONS} -qmldir=${MK_QT_QMLDIR})
		endif ()

	else ()

		mk_message(SEND_ERROR "The Qt deployment tool doesn't support the target operation system!")
		return()

	endif ()
endfunction()
