
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")
set(CMAKE_CONFIGURATION_TYPES Debug Release)
project(dll1_solution)

# config header based on input
option(DLL1_PRINTER_ENABLED 
	"use Printer for Util to print. if OFF, Util will use its own method to print" 
	ON)

set(header_config_dir "${CMAKE_CURRENT_BINARY_DIR}/dll1_config")
set(header_config_name "dll1_config.h")
configure_file(dll1_config.h.in "${header_config_dir}/${header_config_name}")


# add subdirectories
if(DLL1_PRINTER_ENABLED)
  add_subdirectory(printer)
endif()
add_subdirectory(util)


# add overall package config file

# config package
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/Dll1ConfigVersion.cmake"
  VERSION "1.1.4"
  COMPATIBILITY AnyNewerVersion
  )

# define custom properties to export
string(CONCAT path_on_config 
    $<$<CONFIG:Debug>:debug>
    $<$<CONFIG:Release>:release>
    )
set(install_dir "\${PACKAGE_PREFIX_DIR}")
set(cmake_dir "\${PACKAGE_PREFIX_DIR}/cmake")
set(include_dir "\${PACKAGE_PREFIX_DIR}/${path_on_config}/include")
set(runtime_dir "\${PACKAGE_PREFIX_DIR}/${path_on_config}/bin")

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/Dll1Config.cmake"
  INSTALL_DESTINATION cmake
  )

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/Dll1Config.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/Dll1ConfigVersion.cmake"
  DESTINATION cmake
  )

