#
# Vulkan
# https://cmake.org/cmake/help/v3.10/module/FindVulkan.html
#

if (MK_VULKAN)
	find_package(Vulkan REQUIRED)
    
	if (NOT Vulkan_FOUND)
		mk_message(FATAL_ERROR "Vulkan libraries cannot be found!")
		return()
	endif ()
    
	target_link_libraries(${PROJECT_NAME} Vulkan::Vulkan)
	mk_target_deploy_libraries(${PROJECT_NAME} Vulkan::Vulkan)
endif ()
