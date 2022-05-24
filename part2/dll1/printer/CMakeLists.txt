
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CONFIGURATION_TYPES Debug Release)


# target
# NOTE: always regenerate (cmake ../) before build (cmake --build .) to get the newest list of source files.
# otherwise, the generated build folder doesnot know if new source files are added or removed.
set(TARGET_NAME Printer)
file(GLOB_RECURSE CPP_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(${TARGET_NAME} SHARED ${CPP_FILES})

# set header files and needed files (resources, configs, ...) for easy installing.
# use file_set for install and export (version 3.23).
file(GLOB_RECURSE H_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
list(APPEND H_FILES "${header_config_dir}/${header_config_name}")
target_sources(${TARGET_NAME} PUBLIC
    FILE_SET HEADERS
    BASE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/src;${header_config_dir}"
    FILES ${H_FILES}
    )

string(CONCAT path_on_config 
    # ${TARGET_NAME}/ 
    $<$<CONFIG:Debug>:debug>
    $<$<CONFIG:Release>:release>
    # $<$<BOOL:${CMAKE_GENERATOR_PLATFORM}>:_${CMAKE_GENERATOR_PLATFORM}>
    )

# set postfix
set_target_properties(${TARGET_NAME} PROPERTIES DEBUG_POSTFIX "_d")

# include dirs
target_include_directories(${TARGET_NAME} PUBLIC 
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src;${header_config_dir}>"
    "$<INSTALL_INTERFACE:./${path_on_config}/include>"  # must be relative
    )

# define macros
target_compile_definitions(${TARGET_NAME} 
 PRIVATE
 "DLL1_PRINTER_EXPORT"
 $<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},Win32;WIN32>:DLL1_UTIL_WIN32> 
 $<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},x64;>:DLL1_UTIL_X64> 
 $<$<CONFIG:Debug>:DLL1_UTIL_DEBUG>
 $<$<CONFIG:Release>:DLL1_UTIL_RELEASE>
 )

# compiler options
set(warning_options
    "$<$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>:-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused>"
    "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/W3>")
target_compile_options(${TARGET_NAME} PRIVATE ${warning_options})


# link libs
# no lib.


# install

install(TARGETS ${TARGET_NAME}
    EXPORT PrinterTarget
    LIBRARY DESTINATION ${path_on_config}/lib
    ARCHIVE DESTINATION ${path_on_config}/lib
    
    RUNTIME DESTINATION ${path_on_config}/bin
    COMPONENT printer_runtime

    FILE_SET HEADERS DESTINATION ${path_on_config}/include # install headers, version 3.23
    COMPONENT printer_header
    )

# exprort target
install(EXPORT PrinterTarget
        FILE PrinterTarget.cmake
        NAMESPACE dll1::
        DESTINATION cmake
)


# read version string from source file
include(${CMAKE_CURRENT_SOURCE_DIR}/../util23.cmake)

get_version_from_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/src/printer/version.h"
    "DLL1_PRINTER_VERSION[ \t]+\"([^/ \t\n\r]+)\"[/ \t\n\r]*"
    VERSION_FULL
    DEBUG
    )
message(STATUS "VERSION_FULL: ${VERSION_FULL}")


# config package
include(CMakePackageConfigHelpers)

set_property(TARGET ${TARGET_NAME} PROPERTY VERSION ${VERSION_FULL})
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/PrinterConfigVersion.cmake"
  VERSION "${VERSION_FULL}"
  COMPATIBILITY AnyNewerVersion
  )

# define custom properties to export
set(install_dir "\${PACKAGE_PREFIX_DIR}")
set(cmake_dir "\${PACKAGE_PREFIX_DIR}/cmake")
set(include_dir "\${PACKAGE_PREFIX_DIR}/${path_on_config}/include")
set(runtime_dir "\${PACKAGE_PREFIX_DIR}/${path_on_config}/bin")

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/PrinterConfig.cmake"
  INSTALL_DESTINATION cmake
  )

install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/PrinterConfig.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/PrinterConfigVersion.cmake"
  DESTINATION cmake
  )

