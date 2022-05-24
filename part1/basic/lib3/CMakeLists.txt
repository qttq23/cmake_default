
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CONFIGURATION_TYPES Debug Release)
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")
project(lib3_solution)

# target
# NOTE: always regenerate (cmake ../) before build (cmake --build .) to get the newest list of source files.
# otherwise, the generated build folder doesnot know if new source files are added or removed.
set(TARGET_NAME Lib3)
file(GLOB_RECURSE CPP_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(${TARGET_NAME} STATIC ${CPP_FILES})


# set header files and needed files (resources, configs, ...) for easy installing.
# use file_set for install and export (version 3.23).
file(GLOB_RECURSE H_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
target_sources(${TARGET_NAME} PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/src
    FILES ${H_FILES}
    )
# # for older version,
# # use a target property to store where all needed files will be installed.
# # downstream targets and dependents can use this property with install(DIRECTORY).
string(CONCAT path_on_config 
                        # ${TARGET_NAME}/ 
                        $<$<CONFIG:Debug>:debug>
                        $<$<CONFIG:Release>:release>
                        # $<$<BOOL:${CMAKE_GENERATOR_PLATFORM}>:_${CMAKE_GENERATOR_PLATFORM}>
                         )

# set(INSTALL_HEADER_DIR "${path_on_config}/include_manual")
# set_target_properties(${TARGET_NAME} PROPERTIES 
#     ${TARGET_NAME}_INSTALL_HEADER_DIR "${CMAKE_INSTALL_PREFIX}/${INSTALL_HEADER_DIR}"
#     INTERFACE_${TARGET_NAME}_INSTALL_HEADER_DIR "\${_IMPORT_PREFIX}/${INSTALL_HEADER_DIR}")
# set_property(TARGET ${TARGET_NAME} APPEND PROPERTY
#   COMPATIBLE_INTERFACE_STRING "${TARGET_NAME}_INSTALL_HEADER_DIR"
# )

# set postfix
set_target_properties(${TARGET_NAME} PROPERTIES DEBUG_POSTFIX "_d")

# include dirs
target_include_directories(${TARGET_NAME} PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    )

# define macros
target_compile_definitions(${TARGET_NAME} 
							PRIVATE
							$<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},Win32;WIN32>:LIB3_WIN32> 
                            $<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},x64;>:LIB3_X64> 
                            $<$<CONFIG:Debug>:LIB3_DEBUG>
                            $<$<CONFIG:Release>:LIB3_RELEASE>
                            
                            INTERFACE "LIB3_LOGGER_ENABLED"
                            )

# compiler options
set(warning_options
    "$<$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>:-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused>"
    "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/W3>")
target_compile_options(${TARGET_NAME} PRIVATE ${warning_options})


# install       
# runtime, lib, headers
# install(TARGETS ${TARGET_NAME}
#     LIBRARY DESTINATION ${path_on_config}/lib  	# .a files
#     ARCHIVE DESTINATION ${path_on_config}/lib   # .lib files on Windows
#     # RUNTIME DESTINATION ${path_on_config}/bin   # .dll files on Windows
#     FILE_SET HEADERS DESTINATION ${path_on_config}/include # install headers, version 3.23
#     )

install(TARGETS ${TARGET_NAME}
    LIBRARY DESTINATION ${path_on_config}/lib   # .a files
    ARCHIVE DESTINATION ${path_on_config}/lib   # .lib files on Windows
    # RUNTIME DESTINATION ${path_on_config}/bin   # .dll files on Windows
    
    FILE_SET HEADERS DESTINATION ${path_on_config}/include # install headers, version 3.23
    COMPONENT lib3_header

    )

