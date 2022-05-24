
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CONFIGURATION_TYPES Debug Release)
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install")
project(app_solution)

# target
# NOTE: always regenerate (cmake ../) before build (cmake --build .) to get the newest list of source files.
# otherwise, the generated build folder doesnot know if new source files are added or removed.
set(TARGET_NAME App1)
file(GLOB_RECURSE CPP_FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
add_executable(${TARGET_NAME} ${CPP_FILES})

# set postfix
set_target_properties(${TARGET_NAME} PROPERTIES DEBUG_POSTFIX "_d")

# link libs
target_link_libraries(${TARGET_NAME} PUBLIC Dll1 Dll2 Lib3)


# include dirs
target_include_directories(${TARGET_NAME} PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    )

# define macros
target_compile_definitions(${TARGET_NAME} 
	PRIVATE "_CRT_SECURE_NO_WARNINGS")

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

# install(TARGETS ${TARGET_NAME} 
# 	RUNTIME DESTINATION ${path_on_config}/bin
# 	)

# # install runtime of dll1
# get_target_property(imported_runtime1_dirs Dll1 HEADER_DIRS_runtime)
# foreach(dir IN LISTS imported_runtime1_dirs)
# 	# add '/' to each directory to prevent install(directory) from copying the last folder.
# 	install(DIRECTORY "${dir}/" DESTINATION ${path_on_config}/bin)
# endforeach()

# # install runtime of dll2
# get_target_property(imported_runtime2_dirs Dll2 HEADER_DIRS_runtime)
# foreach(dir IN LISTS imported_runtime2_dirs)
# 	# add '/' to each directory to prevent install(directory) from copying the last folder.
# 	install(DIRECTORY "${dir}/" DESTINATION ${path_on_config}/bin)
# endforeach()


install(TARGETS ${TARGET_NAME} 
	RUNTIME DESTINATION ${path_on_config}/bin
	)

install(CODE "
    execute_process(
    COMMAND cmake 
    --install \"${CMAKE_BINARY_DIR}\"  
    --component dll1_runtime 
    --config \"$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>\" 
    --prefix \"\${CMAKE_INSTALL_PREFIX}\" 
    )
    ")

install(CODE "
    execute_process(
    COMMAND cmake 
    --install \"${CMAKE_BINARY_DIR}\"
    --component dll2_runtime 
    --config \"$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>\" 
    --prefix \"\${CMAKE_INSTALL_PREFIX}\" 
    )
    ")

install(CODE "
    execute_process(
    COMMAND cmake 
    --install \"${CMAKE_BINARY_DIR}\"  
    --component lib3_runtime 
    --config \"$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>\" 
    --prefix \"\${CMAKE_INSTALL_PREFIX}\"
    )
    ")


