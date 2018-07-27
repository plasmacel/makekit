#
# OpenMP
# https://cmake.org/cmake/help/v3.10/module/FindOpenMP.html
#

if (MK_OPENMP)
	if (TRUE) # Use LLVM libomp
		set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} "") # Append empty string to the list of library prefixes
		find_library(MK_LIBOMP_LIB libomp PATHS $ENV{MK_LLVM_DIR}/lib REQUIRED) # add NO_DEFAULT_PATH to restrict to LLVM-installed libomp

		if (NOT MK_LIBOMP_LIB)
			mk_message(FATAL_ERROR "OpenMP (libomp) libraries cannot be found!")
			return()
		endif ()
	
		if (MK_OS_WINDOWS)
			target_compile_options(${PROJECT_NAME} PRIVATE -Xclang -fopenmp)
		else ()
			target_compile_options(${PROJECT_NAME} PRIVATE -fopenmp=libomp)
		endif ()
		
		target_link_libraries(${PROJECT_NAME} ${MK_LIBOMP_LIB})
		mk_target_deploy_libraries(${PROJECT_NAME} ${MK_LIBOMP_LIB})
	else ()
		find_package(OpenMP REQUIRED)

		if (NOT OpenMP_FOUND)
			mk_message(FATAL_ERROR "OpenMP libraries cannot be found!")
			return()
		endif ()
		
		target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
		mk_target_deploy_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
	endif ()
endif ()
