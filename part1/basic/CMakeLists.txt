
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")
set(CMAKE_CONFIGURATION_TYPES Debug Release)
project(basic_solution)

# below order is important 
add_subdirectory(lib3)
add_subdirectory(dll2)
add_subdirectory(dll1)
add_subdirectory(app)