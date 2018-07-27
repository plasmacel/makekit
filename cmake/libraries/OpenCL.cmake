#
# OpenCL
# https://cmake.org/cmake/help/v3.10/module/FindOpenCL.html
#

if (MK_OPENCL)
	find_package(OpenCL REQUIRED)
    
	if (NOT OpenCL_FOUND)
		mk_message(FATAL_ERROR "OpenCL libraries cannot be found!")
		return()
	endif ()
    
	target_link_libraries(${PROJECT_NAME} OpenCL::OpenCL)
	mk_target_deploy_libraries(${PROJECT_NAME} OpenCL::OpenCL)
endif ()
