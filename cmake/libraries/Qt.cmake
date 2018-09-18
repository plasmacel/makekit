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

#
# Qt
# http://doc.qt.io/qt-5/qtmodules.html
# http://doc.qt.io/qt-5/cmake-manual.html#imported-targets
#

set(MK_CXX_QRCFILE_SUFFIX *.qrc)
set(MK_CXX_UIFILE_SUFFIX *.ui)

function(mk_target_link_Qt TARGET_NAME)

	# Find Qt5

	set(Qt5_DIR $ENV{MK_QT_DIR}/lib/cmake/Qt5)
	find_package(Qt5 COMPONENTS ${ARGN} REQUIRED)

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

	set_target_properties(${TARGET_NAME} PROPERTIES AUTOMOC ON) # Automatically execute moc on required C++ files
	set_target_properties(${TARGET_NAME} PROPERTIES AUTORCC ON) # Automatically execute rcc on .qrc files
	set_target_properties(${TARGET_NAME} PROPERTIES AUTOUIC ON) # Automatically execute uic on .ui files

	# Add Qt source files to the target (they are being appended to its SOURCE property)

	file(GLOB_RECURSE CXX_QRCFILES ${MK_CONFIGURE_DEPENDS} *.qrc)
	file(GLOB_RECURSE CXX_UIFILES ${MK_CONFIGURE_DEPENDS} *.ui)

	target_sources(${TARGET_NAME} PRIVATE ${CXX_QRCFILES} PRIVATE ${CXX_UIFILES})

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

	foreach (QT_MODULE IN ITEMS ${ARGN})
		if (NOT ${QT_MODULE} IN_LIST ALL_QT_MODULES)
			mk_message(SEND_ERROR "Skipping invalid Qt module: ${QT_MODULE}")
			continue()
		endif ()
		
		target_link_libraries(${TARGET_NAME} ${LINK_SCOPE} Qt5::${QT_MODULE}) # Qt5::Core Qt5::Gui Qt5::OpenGL Qt5::Widgets Qt5::Network
		mk_target_deploy_libraries(${TARGET_NAME} Qt5::${QT_MODULE})
	endforeach ()
	
endfunction()

function(mk_target_deploy_Qt TARGET_NAME)
	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (NOT TARGET_TYPE STREQUAL "EXECUTABLE")
		mk_message(SEND_ERROR "Qt deployment requires an EXECUTABLE target")
		return()
	endif ()

	if (MK_OS_WINDOWS)

		#add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND "windeployqt "${TARGET_NAME}".exe")
		add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/windeployqt $<TARGET_FILE:${TARGET_NAME}>)

	elseif (MK_OS_MACOS)
			
		get_target_property(TARGET_IS_BUNDLE ${TARGET_NAME} MACOSX_BUNDLE)

		if (NOT TARGET_IS_BUNDLE)
			mk_message(SEND_ERROR "Qt deployment on macOS requires an application bundle target")
			return()
		endif ()

		add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/macdeployqt $<TARGET_BUNDLE_DIR:${TARGET_NAME}>)

	elseif (MK_OS_LINUX)

		add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND $ENV{MK_QT_DIR}/bin/linuxdeployqt $<TARGET_FILE:${TARGET_NAME}> -qmake=$ENV{MK_QT_DIR}/bin/qmake)

	endif ()
endfunction()
