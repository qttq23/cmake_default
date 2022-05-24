
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")
set(CMAKE_CONFIGURATION_TYPES Debug Release)
project(app_solution)


# below order is important 
# using script to resolve dependencies
include(${CMAKE_CURRENT_SOURCE_DIR}/util23.cmake)
set(input_list "app1;lib")
set(app1_list "lib")	# app1 depends on lib
sort_dependencies(input_list output_list DEBUG)
message(STATUS "success sort_dependencies: ${output_list}")
foreach(item IN LISTS output_list)
	add_subdirectory(${item})	# add in order
endforeach()
