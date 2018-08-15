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
# OpenCL
# https://cmake.org/cmake/help/v3.10/module/FindOpenCL.html
#

function(mk_target_link_OpenCL TARGET_NAME)

	find_package(OpenCL REQUIRED)
    
	if (NOT OpenCL_FOUND)
		mk_message(FATAL_ERROR "OpenCL libraries cannot be found!")
		return()
	endif ()

	get_target_property(TARGET_TYPE ${TARGET_NAME} TYPE)

	if (${TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")
		set(LINK_SCOPE INTERFACE)
	else ()
		unset(LINK_SCOPE)
	endif ()
    
	target_link_libraries(${TARGET_NAME} ${LINK_SCOPE} OpenCL::OpenCL)
	mk_target_deploy_libraries(${TARGET_NAME} OpenCL::OpenCL)

endfunction()
