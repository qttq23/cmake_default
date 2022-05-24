
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CONFIGURATION_TYPES Debug Release)
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")
project(dll2_solution)


# target
# NOTE: always regenerate (cmake ../) before build (cmake --build .) to get the newest list of source files.
# otherwise, the generated build folder doesnot know if new source files are added or removed.
set(TARGET_NAME Dll2)
file(GLOB_RECURSE CPP_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_library(${TARGET_NAME} SHARED ${CPP_FILES})

# set header files and needed files (resources, configs, ...) for easy installing.
# use file_set for install and export (version 3.23).
file(GLOB_RECURSE H_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
target_sources(${TARGET_NAME} PUBLIC
    FILE_SET HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/src
    FILES ${H_FILES}
    )


# set postfix
set_target_properties(${TARGET_NAME} PROPERTIES DEBUG_POSTFIX "_d")

# link to lib3
target_link_libraries(${TARGET_NAME} PUBLIC Lib3)


# include dirs
target_include_directories(${TARGET_NAME} PUBLIC 
	${CMAKE_CURRENT_SOURCE_DIR}/src
    )

# define macros
target_compile_definitions(${TARGET_NAME} PRIVATE 
    "DLL2_EXPORT" 
    $<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},Win32;WIN32>:DLL2_WIN32> 
    $<$<IN_LIST:${CMAKE_GENERATOR_PLATFORM},x64;>:DLL2_X64> 
    $<$<CONFIG:Debug>:DLL2_DEBUG>
    $<$<CONFIG:Release>:DLL2_RELEASE>

    INTERFACE "DLL2_IMPORT"
    )

# compiler options
set(warning_options
    "$<$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>:-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused>"
    "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/W3>")
target_compile_options(${TARGET_NAME} PRIVATE ${warning_options})


# # install       
string(CONCAT path_on_config 
  # ${TARGET_NAME}/ 
  $<$<CONFIG:Debug>:debug>
  $<$<CONFIG:Release>:release>
  # $<$<BOOL:${CMAKE_GENERATOR_PLATFORM}>:_${CMAKE_GENERATOR_PLATFORM}>
  )

# # set dll2's runtime install-dir for downstream to install
# target_sources(${TARGET_NAME} PUBLIC
#     FILE_SET runtime
#     TYPE HEADERS
#     BASE_DIRS ${CMAKE_INSTALL_PREFIX}/${path_on_config}/bin
#     )

# # append dll2's file_set with content of Lib3's file_set
# # so that downstream of dll2 and dll2 can have all needed file_set
# get_target_property(imported_ic_dirs Lib3 HEADER_DIRS)
# get_target_property(imported_ic_files Lib3 HEADER_SET)
# target_sources(${TARGET_NAME} PUBLIC
#     FILE_SET HEADERS
#     BASE_DIRS "${imported_ic_dirs}"
#     FILES "${imported_ic_files}"
#     )

# # runtime, lib, headers
# install(TARGETS ${TARGET_NAME}
#     LIBRARY DESTINATION ${path_on_config}/lib  	# .a files
#     ARCHIVE DESTINATION ${path_on_config}/lib   # .lib files on Windows
#     RUNTIME DESTINATION ${path_on_config}/bin   # .dll files on Windows
#     FILE_SET HEADERS DESTINATION ${path_on_config}/include # install headers, version 3.23

#     # below installs nothing. 
# 	# but useful when export, its path will be replaced to be relative to install dir. 
# 	FILE_SET runtime DESTINATION ${path_on_config}/bin	
#     )


# runtime, lib, headers
install(TARGETS ${TARGET_NAME}
    LIBRARY DESTINATION ${path_on_config}/lib     # .a files
    ARCHIVE DESTINATION ${path_on_config}/lib   # .lib files on Windows
    
    RUNTIME DESTINATION ${path_on_config}/bin   # .dll files on Windows
    COMPONENT dll2_runtime

    FILE_SET HEADERS DESTINATION ${path_on_config}/include # install headers, version 3.23   
    COMPONENT dll2_header
    )

install(CODE "
    execute_process(
    COMMAND cmake 
    --install \"${CMAKE_BINARY_DIR}\"  
    --component lib3_header 
    --config \"$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>\" 
    --prefix \"\${CMAKE_INSTALL_PREFIX}\" 
    )
    " COMPONENT dll2_header)

install(CODE "
    execute_process(
    COMMAND cmake 
    --install \"${CMAKE_BINARY_DIR}\"  
    --component lib3_runtime 
    --config \"$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>\" 
    --prefix \"\${CMAKE_INSTALL_PREFIX}\" 
    )
    " COMPONENT dll2_runtime)

