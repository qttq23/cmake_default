
# required version
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# actions
set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO STDOUT)

while(1 EQUAL 1)

	# build x86
	set(build_dir "${CMAKE_CURRENT_SOURCE_DIR}/build_win32")
	execute_process( 
		COMMAND cmake -E make_directory "${build_dir}" 
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake -G "Visual Studio 17 2022" -A Win32 ".."
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --build . --config Debug
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --build . --config Release
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --install . --config Debug
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --install . --config Release
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()


	# build x64
	set(build_dir "${CMAKE_CURRENT_SOURCE_DIR}/build_x64")
	execute_process( 
		COMMAND cmake -E make_directory "${build_dir}" 
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake -G "Visual Studio 17 2022" -A x64 ".."
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --build . --config Debug
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --build . --config Release
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --install . --config Debug
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	execute_process(
		COMMAND cmake --install . --config Release
		WORKING_DIRECTORY ${build_dir}
		RESULT_VARIABLE retCode)
	if(NOT retCode EQUAL 0) 
		break() 
	endif()

	# # open explorer
	# if(WIN32)
	# 	execute_process(
	# 		COMMAND cmd /c explorer .
	# 		WORKING_DIRECTORY ${build_dir}/install
	# 		)
	# endif()

	# finish
	break()

endwhile()

# show result
if(retCode EQUAL 0)
	message(STATUS "run successfully")
else()
	message(FATAL_ERROR "fail with code ${retCode}")
endif()




