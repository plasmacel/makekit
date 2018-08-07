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
# OpenGL
# https://cmake.org/cmake/help/v3.10/module/FindOpenGL.html
#

function(mk_target_link_OpenGL TARGET_NAME)

	find_package(OpenGL REQUIRED)
		
	if (NOT OpenGL_FOUND)
		mk_message(FATAL_ERROR "OpenGL libraries cannot be found!")
		return()
	endif ()

	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (${TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")
		set(MK_LINK_SCOPE INTERFACE)
	else ()
		unset(MK_LINK_SCOPE)
	endif ()

	target_link_libraries(${TARGET_NAME} ${MK_LINK_SCOPE} OpenGL::GL)
	mk_target_deploy_libraries(${TARGET_NAME} OpenGL::GL)

	#if (OpenGL::OpenGL)
	#	target_link_libraries(${TARGET_NAME} OpenGL::OpenGL)
	#	mk_target_deploy_libraries(${TARGET_NAME} OpenGL::OpenGL)
	#else ()
	#	target_link_libraries(${TARGET_NAME} OpenGL::GL)
	#	mk_target_deploy_libraries(${TARGET_NAME} OpenGL::GL)
	#endif ()

endfunction()
