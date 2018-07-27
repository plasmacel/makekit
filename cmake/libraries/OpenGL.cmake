#
# OpenGL
# https://cmake.org/cmake/help/v3.10/module/FindOpenGL.html
#

if (MK_OPENGL)
	find_package(OpenGL REQUIRED)
		
	if (NOT OpenGL_FOUND)
		mk_message(FATAL_ERROR "OpenGL libraries cannot be found!")
		return()
	endif ()

	target_link_libraries(${PROJECT_NAME} OpenGL::GL)
	mk_target_deploy_libraries(${PROJECT_NAME} OpenGL::GL)

	#if (OpenGL::OpenGL)
	#	target_link_libraries(${PROJECT_NAME} OpenGL::OpenGL)
	#	mk_target_deploy_libraries(${PROJECT_NAME} OpenGL::OpenGL)
	#else ()
	#	target_link_libraries(${PROJECT_NAME} OpenGL::GL)
	#	mk_target_deploy_libraries(${PROJECT_NAME} OpenGL::GL)
	#endif ()
endif ()
