
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CONFIGURATION_TYPES Debug Release)
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")


# target
# NOTE: always regenerate (cmake ../) before build (cmake --build .) to get the newest list of source files.
# otherwise, the generated build folder doesnot know if new source files are added or removed.
set(TARGET_NAME Logger)
file(GLOB_RECURSE CPP_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(${TARGET_NAME} SHARED ${CPP_FILES})

# set header files
# use file_set for install (version 3.23).
file(GLOB_RECURSE H_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
target_sources(${TARGET_NAME} PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/src
    FILES ${H_FILES}
    )

string(CONCAT path_on_config 
    # ${TARGET_NAME}/ 
    $<$<CONFIG:Debug>:debug>
    $<$<CONFIG:Release>:release>
    # # $<$<BOOL:${CMAKE_GENERATOR_PLATFORM}>:_${CMAKE_GENERATOR_PLATFORM}>
    )


# set postfix
set_target_properties(${TARGET_NAME} PROPERTIES DEBUG_POSTFIX "_d")

# include dirs
target_include_directories(${TARGET_NAME} PUBLIC 
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>"
    
    "$<INSTALL_INTERFACE:./${path_on_config}/include>"  
    # the './' is to make it a relative path.
    # relative path will be prepended with path to install folder by cmake.
    )

# define macros
target_compile_definitions(${TARGET_NAME} 
 PRIVATE
 "LOGGER_EXPORT"
 $<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},Win32;WIN32>:LOGGER_WIN32> 
 $<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},x64;>:LOGGER_X64> 
 $<$<CONFIG:Debug>:LOGGER_DEBUG>
 $<$<CONFIG:Release>:LOGGER_RELEASE>

 INTERFACE "DLL2_LOGGER_ENABLED"
 )

# compiler options
set(warning_options
    "$<$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>:-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused>"
    "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/W3>")
target_compile_options(${TARGET_NAME} PRIVATE ${warning_options})


# install       
# runtime, lib, headers
install(TARGETS ${TARGET_NAME}
    EXPORT LoggerTarget
    LIBRARY DESTINATION ${path_on_config}/lib  	# .a files
    ARCHIVE DESTINATION ${path_on_config}/lib   # .lib files on Windows
    RUNTIME DESTINATION ${path_on_config}/bin   # .dll files on Windows
    FILE_SET HEADERS DESTINATION ${path_on_config}/include # install headers, version 3.23
    )

# export target
install(EXPORT LoggerTarget
    FILE LoggerTarget.cmake
    NAMESPACE dll2::
    # DESTINATION ${path_on_config}/cmake  # will fail
    DESTINATION cmake
    )


# read version string from source file
include(${CMAKE_CURRENT_SOURCE_DIR}/../util23.cmake)

get_version_from_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/logger/version.h"
    "LOGGER_VERSION[ \t]+\"([^/ \t\n\r]+)\"[/ \t\n\r]*"
    VERSION_FULL
    DEBUG
    )
message(STATUS "VERSION_FULL: ${VERSION_FULL}")
get_version_from_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/logger/version.h"
    "LOGGER_VERSION_MAJOR[ \t]+\"([^/ \t\n\r]+)\"[/ \t\n\r]*"
    VERSION_MAJOR
    DEBUG
    )
message(STATUS "VERSION_MAJOR: ${VERSION_MAJOR}")


# config package
include(CMakePackageConfigHelpers)

set_property(TARGET ${TARGET_NAME} PROPERTY VERSION ${VERSION_FULL})
set_property(TARGET ${TARGET_NAME} PROPERTY
  INTERFACE_${TARGET_NAME}_MAJOR_VERSION ${VERSION_MAJOR})
set_property(TARGET ${TARGET_NAME} APPEND PROPERTY
  COMPATIBLE_INTERFACE_STRING ${TARGET_NAME}_MAJOR_VERSION
  )
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/LoggerConfigVersion.cmake"
  VERSION "${VERSION_FULL}"
  COMPATIBILITY AnyNewerVersion
  )

# define custom properties to export

set(install_dir "\${PACKAGE_PREFIX_DIR}")
set(cmake_dir "\${PACKAGE_PREFIX_DIR}/cmake")
set(include_dir "\${PACKAGE_PREFIX_DIR}/${path_on_config}/include")
set(runtime_dir "\${PACKAGE_PREFIX_DIR}/${path_on_config}/bin")

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/LoggerConfig.cmake"
  INSTALL_DESTINATION cmake
  )

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/LoggerConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/LoggerConfigVersion.cmake"
  DESTINATION cmake
  )


# # export to build tree
# export(EXPORT LoggerTarget
#  FILE "${CMAKE_CURRENT_BINARY_DIR}/cmake/LoggerTarget.cmake"
#  NAMESPACE dll2::
#  )

# write_basic_package_version_file(
#   "${CMAKE_CURRENT_BINARY_DIR}/local/LoggerConfigVersion.cmake"
#   VERSION "${VERSION_FULL}"
#   COMPATIBILITY AnyNewerVersion
#   )

# # custom properties
# set(header_basedirs_export "${header_basedirs}")
# set(header_files_export "${header_files}")
# set(helper_script_export "${helper_script}")
# set(is_export_export OFF)

# configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
#   "${CMAKE_CURRENT_BINARY_DIR}/local/LoggerConfig.cmake"
#   INSTALL_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/cmake
#   )
# install(FILES
#   "${CMAKE_CURRENT_BINARY_DIR}/local/LoggerConfig.cmake"
#   "${CMAKE_CURRENT_BINARY_DIR}/local/LoggerConfigVersion.cmake"
#   DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/cmake
#   )
