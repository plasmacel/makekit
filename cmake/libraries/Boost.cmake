#
# Boost
# https://cmake.org/cmake/help/v3.10/module/FindBoost.html
#

if (MK_BOOST)
	find_package(Boost COMPONENTS ${MK_BOOST} REQUIRED)
    
	if (NOT Boost_FOUND)
		mk_message(FATAL_ERROR "Boost libraries cannot be found!")
		return()
	endif ()

	foreach (BOOST_MODULE ${MK_BOOST})
		target_link_libraries(${PROJECT_NAME} Boost::${BOOST_MODULE})
		mk_target_deploy_libraries(${PROJECT_NAME} Boost::${BOOST_MODULE})
	endforeach ()
endif ()
