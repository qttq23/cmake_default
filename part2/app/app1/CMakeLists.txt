
# specify the C++ standard
cmake_minimum_required(VERSION 3.23)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CONFIGURATION_TYPES Debug Release)

# target
# NOTE: always regenerate (cmake ../) before build (cmake --build .) to get the newest list of source files.
# otherwise, the generated build folder doesnot know if new source files are added or removed.
set(TARGET_NAME App1)
file(GLOB_RECURSE CPP_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
add_executable(${TARGET_NAME} ${CPP_FILES})


# include dirs
target_include_directories(${TARGET_NAME} PUBLIC 
	"${CMAKE_CURRENT_SOURCE_DIR}/src"
	)

# define macros
target_compile_definitions(${TARGET_NAME} 
	PRIVATE "_CRT_SECURE_NO_WARNINGS")

# compiler options
set(warning_options
	"$<$<COMPILE_LANG_AND_ID:CXX,ARMClang,AppleClang,Clang,GNU,LCC>:-Wall;-Wextra;-Wshadow;-Wformat=2;-Wunused>"
	"$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/W3>")
target_compile_options(${TARGET_NAME} PRIVATE ${warning_options})


# link libs
target_link_libraries(${TARGET_NAME} PRIVATE AbcLib)

list(APPEND CMAKE_PREFIX_PATH 
	"${CMAKE_SOURCE_DIR}/../dll1/build_${CMAKE_GENERATOR_PLATFORM}/install/cmake")
	# "${CMAKE_SOURCE_DIR}/../dll1/build/install/cmake")	# printer not enabled

find_package(Dll1 1.1.4 REQUIRED COMPONENTS Util Printer)
target_link_libraries(${TARGET_NAME} PUBLIC dll1::Util dll1::Printer)
# find_package(Dll1 1.1.4 REQUIRED COMPONENTS Util)
# target_link_libraries(${TARGET_NAME} PUBLIC dll1::Util)


# install
string(CONCAT path_on_config 
	# ${TARGET_NAME}/ 
	$<$<CONFIG:Debug>:debug>
	$<$<CONFIG:Release>:release>
	# $<$<BOOL:${CMAKE_GENERATOR_PLATFORM}>:_${CMAKE_GENERATOR_PLATFORM}>
	)

install(TARGETS ${TARGET_NAME} 
	RUNTIME DESTINATION ${path_on_config}/bin
	)

install(CODE "
	execute_process(
	COMMAND cmake 
	--install \"${CMAKE_BINARY_DIR}\"  
	--component Abc_header 
	--config \"$<$<CONFIG:Debug>:Debug>$<$<CONFIG:Release>:Release>\" 
	--prefix \"\${CMAKE_INSTALL_PREFIX}\" 
	)
	")

# install dll1
install(DIRECTORY "${Dll1_runtime_dir}/" DESTINATION ${path_on_config}/bin)



