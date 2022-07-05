# cmake tutorial summary (version 3.23, Windows)

## part 1: basic structure, config, build, install

solution 'basic'. it has 1 app and 4 libraries that the app depends on.
app: depends dll1, dll2, lib3
dll1: depends dll2
dll2: depends lib3
lib3: independent

CMake is target-oriented. A target is something can be built to produce executable (exe), shared library (dll) or static library (lib) and more. A project in cmake is equivalent to a solution in visual studio and a target in cmake is similar to a project in VS term.

The CMakeLists.txt is cmake script that defines targets and projects. Ideally and for simplicity, there should be 1 CMakeLists file in root directory that defines 1 project and add subdirectoies. Each subdirectories should contain 1 CMakeLists that define only 1 target. Don't define target in subdirectory of a subdirectory.

In our example, we create 1 project in the top-level cmakelists file (in 'basic' folder). and define each target in each subdirectory cmakelists file. In subdirectory, defining project is optional. If that target is standalone, does not depend on any other targets, then define a project for it for later you can easily copy this subdirectory to somewhere else to build.

the top-level cmakelists file creates a project and add subdirectories. the order of add_subdirectory is important. the least-depent subdirectory will be placed first.
eg: 
add_subdirectory(lib3)
add_subdirectory(dll2)
add_subdirectory(dll1)
add_subdirectory(app)


ideally, all source/header files should be placed in side a separate folder and that separate folder's name should be the domain name. This is for 2 things: easier/safer to get all source/header files to compile and prevent the header files from name collision (when being included by other targets) by putting them inside the domain-named folder.
eg: in 'app' sudirectory, create a cmakelists file that defined target 'App1'.
beside cmakelists, create a src/app1 folder to act as a domain folder. then put all header/source files into 'src/app1' folder.


A target (eg: Lib3) can be defined as a library and compiled with provided source files. A target can define its include_dir (where to look for header files), compile_definition (marcos) and compile_option (eg: flags to make compiler show warnings). 

Usually, a library installs at least: a link file (.lib for consumer to link to) and dll files (if it is shared library. consumer will need this in runtime) and a set of header files (consumer will include these header files). cmake supports installing link file and runtime file by default. To install header files, put all needed headers in a file_set then install that file_set. file_set will preserve the folder structure of headers. don't use public_header property because it doesnot preserve structure.

(file_set is quite new in version 3.23. For older version, you can simulate the same effect by putting all header base dirs into a variable and all header files into a variable. When install, subtract header file by header base dir, then concat result with install destination, then install header files into concated destination. Doing that can also preserve the header folder structure.)


A target can link to other targets (eg: dll2 links to lib3). If A links B in PUBLIC, B will represent in A's INTERFACE_LINK_LIBRARIES property. Consumer of A, for example C links A, will read A public properties (such as include_dir, macros) and also read B's public properties. If A links B in PRIVATE, B will not present in A's INTERFACE_LINK_LIBRARIES, and therefore comsumers of A only read A's public properties and not have any clue about B. So if A thinks that its consumer don't need to know anything about B, A should link B in PRIVATE. For example, if all headers of A don't include any header of B (maybe only include B's headers in A's cpp files), then consumer of A don't need to know B's include_dir, so A should link B in PRIVATE.

Target's properties (include_dir, macros, options) can be defined as PUBLIC or PRIVATE property. PUBLIC property will be read by consumers while PRIVATE property will be not. In practise, only INCLUDE_DIRECTORIES should be made PUBLIC, so that consumers can read public include_dir when links to. Don't make compile_definitions and compile_options PUBLIC. Imagine in real life, when you download a non-cmake library, it only contains header, lib, dll and the only information you may have is header not the compile_definitions and compile_opitons.

When dll2 installs, beside dll2's artifacts (header, lib, dll), dll2 may need to install headers and runtime (dll) of lib3 too. dll2 doing this by install the COMPONENT that is defined in lib3/cmakelists file. And so on, dll2 can defined some install COMPONENTs for consumer of it (eg: dll1) to later install. Do not call install(Dll2 ...) in dll1's cmakelists, because dll1 might not know which libraries that dll2 are depending on.

(in dll2/cmakelists file, it uses the file(CODE) with generator expression which is available since version 3.14. For older versions, the target can provide its own function for installing. consumer will call that function when they need to install artifacts of dependee target. that function signiture can be: function(lib3_install type destination config).
 
Another method is writing custom script to install. Eg: when user want to install dll2, they can type in terminal: "cmake -Dconfig=Debug -Dprefix=abc/xyz -Dtarget=dll2 -P custom_script.cmake". custom script file will then call cmake command-line that install COMPONENTs defined previously to install needed artifacts for a certain target.)


Above is enough for building and installing those libraries. Don't forget to set the CMAKE_INSTALL_PREFIX in before calling install().

App links to library by specifing library target name. Notice that because we place add_subdirectory in right order (as described above), so the the app's cmakelists can find the targets we specified. Remember when install app1, also install other libraries's runtimes.

(about install folder structure, I recommend all targets inside a root folder should install its artifacts into same generic-name folder such as followings:

install/
    debug/
        lib/
        runtime/
        include/
    release/
        lib/
        runtime/
        include/

This is for clarity and readibility. It is also affected by the COMPONENT feature restriction. Because when you define an install COMPONENT, the DESTINATION attachs to it. And in later call to install that COMPONENT from cmake command-line, the DESTINATION can't be changed, only the prefix can be changed (the final path is : prefix/DESTINATION). Consequently, if consumer (dll2) installs its header in 'dll2_header' folder then it calls install COMPONENT of lib3, headers of lib3 might be installed in different location (may be in 'include' folder). This leads to two header folders in dll2's installed folder. Anyway, COMPONENT feature has its own benefits. So just install into same generic name folder, and if you want to install targets separately, just make different install folder for it (the prefix path) and install all its need artifacts inside that folder. eg:

cmake --install lib3 --config Debug --prefix "install_lib3"

cmake --install dll2 --config Debug --prefix "install_dll2"

Another method to overcome limitation of COMPONENT is that the target provide a function for installing. as described above) 
)


build & install:
go to 'basic' folder and open terminal then type:

mkdir build & cd build

cmake -A Win32 ..

cmake --build . --config Debug

cmake --install . --config Debug

(or build & install separately:
cmake --build . --target Lib3 --config Debug
cmake --install lib3 --config Debug
)

## Note about install .dll dependencies:
below applies for Windows:
- you should first open the `VS developer command prompt` then run cmake commands on that. It will guarantee cmake will find the right tools to build and find dependecies.
- to install dll dependencies, use the command `install(target RUNTIME_DEPENDENCIES DIRECTORIES dir1 dir2 ...)`. replace dir1,dir2 with the folders that contain dll dependencies. cmake will use VisualStudio's dumpbin to find dependencies in those folders and copy those to DESTINATION. 

## part 2: export, import, custom module file, include version parser

context: 
project app has targets: App1, Lib
project dll1 has target: Util, Printer
project dll2 has target: Logger

App1 depends on Lib, Util, Printer.
Util (dll1) depends on Logger (dll2) and optionally Printer (dll1).
Printer (dll1) is independent.
Logger (dll2) is independent.

Notice that these targets are in separate projects, not in the same project as part 1.
Because they are not in the same build tree, they have no clue about each other. So that in order to link a target to other targets, each project has to create an export file for others to import.

In practice, the power of import/export comes when you encounter 3rd library that support cmake. For example, you write your application using cmake and want to use wxWidgets GUI library (which supports cmake) for making GUI. wxWidgets allows building for different platforms (windows, linux, macosx, ...). Each build may contain different paths for include_dir as well as different values for compile_definitions (macros) and compile_options. If you link to those output files manually, you have to write long CMakeLists file with if/else for each platform. CMake help you solve this by introducing export/import feature. wxWidgets create an export file that contains enough information (include dir, macros, options,..) and comsumers (such as your app) can import that file and have all needed information to link to wxWidgets target.


Before going to export/import details, we talk a bit about some utilities that can help us speed up some subtle repeative tasks such as config/build/install. CMake allows you to write your logic in cmake script file (.cmake) and then invoke that script to do some works. I recommend using this approach because it is cross-platform. For example the "part2/app/run.cmake"
 is a script for running some command-lines that you usually use: "cmake -A Win32 ..", "cmake --build . --config Debug", "cmake --install . --config Debug".
You can invoke this script by typing: cmake -P run.cmake
or more short typing by putting "cmake -P run.cmake" command into a platform-specific file (.bat on windows and .sh on linux).

Another subtle problems is the order of subdirectories. As i described in part 1, the less-depent subdirectories has to be added before others. But when project becomes bigger, lots of subdirectory depend on each other. It's a lot messy if we try to solve order by hand. So i wrote a script file that can solve order of subdirectories. just refer to "part2/app/cmakelists.txt" for more details.


Back to export/import topic. We first implement dll2. dll2 defines a Logger target as usual. it is a shared library, has include_dir, macros, options. In the install() command, along with installing file to destination, it adds 'EXPORT LoggerTarget' to grab target information and put those into export file. the command install(export ...) installs that export file in some temp folder. when user type command-line to install (eg: cmake --install . --config Debug) that export file is actually installed to the specified destination. Note that when export, only some interface_* properties are chosen such as interface_include_dir, interface_compile_option, interface_compile_definition. Because when exported, the consumer will use your install folder, not your build or source folder, so every paths in your export file must contains only relative path. Some paths like CMAKE_CURRENT_SOURCE_DIR should not be expanded to export file. To solve this issue, cmake provides INTERFACE_INSTALL and BUILD_INSTALL generator expressions. for example, target_include_directories() uses these expressions to distinguish which include paths to be used when build and when export. (make sure path in INTERFACE_INSTALL is relative by putting './' before your path in case your path starts with generator expression which is by default considered as absolute path)


Next is the package config file and package version file. package config file is just a cmake script file. it includes the target export file above and do some 'configs' such as setting additional target properties. because cmake only put some important target properties into target export file above, so if you want some other properties, set it in package config file. cmake provides you a helper function called 'configure_package_config_file' to write package config file. you first write to package config input file (file ends with .in), you can write variables defined in your cmakelists file to the package config input file, then cmake uses that config input file to write to real package config file with all variables expanded.

cmake also allows you to specify version for your package. just provide version with format 'major.minor.path' to helper function 'write_basic_package_version_file'. I recommend store your version value in your header file in codebase, not in cmake script. when cmake needs your version, cmake should get it from header file (I've write a helper function for this, it basically use regex to find version value). (cmake introduces the way to store version in cmake script and generate header version file to your codebase, but i think it makes your codebase less declarative due to the absence of header version file. so i don't recommend it)

Just like target export file, the package config file and version config file are all generated at config time (when you type: cmake -A x64 ..), not build or install time. so when you want to install them to your install folder, you have to declare the command 'install(files ...)'.


When consumer want to import your package, it call 'find_package(package_name version components...)'. you have to append CMAKE_PREFIX_PATH with the path to folder contains package config file before calling find_package(). find_package() will check if version matchs version specified in version config file. then it check if specified components are found by testing the variable packageName_componentName_FOUND. So in dll2's package config input file, set supported components to ON. for example, package Logger supports component Logger, so you set variable Logger_Logger_FOUND to ON. otherwise, find_package() will fail. 

(The COMPONENTS params in find_package() has the meanings that at least those specified components must exist in package. cmake will pass a list of required components to your pakcage config file and the macro 'check_required_components' will test if packageName_componentName_FOUND is true. you can remove these macro but you should not do it. your package can contain more components imported to consumer at the time consumer calls find_package(). that is reasonable because those components are decided at config time, and some components links to each other. If you exclude those components, consumer might not be built successfully because of missing components.) 


That's a lot about export and import. Now go to dll1. consider dll1 as a larget project that user can choose what components to be included what not. for example, dll1 has 1 mandatory component that is the Util target which always be built and 1 optional component/target Printer. dll1's cmakelists file provide option 'DLL1_PRINTER_ENABLED' for user to choose in config time. if 'DLL1_PRINTER_ENABLED' is ON, the printer subdirectory will be added, then Util target will links to Printer target, also Printer target will be exported. otherwise, if 'DLL1_PRINTER_ENABLED' is OFF, printer subdirectory is not added, Util will not link to Printer and Printer is not exported for consumer project so that the final install artifacts will be reduced in size.

About codebase, after config time, the header config file which defines enabled components will be generated. every source files and header files should include this header config file to know if which components are available and act upon it. for instance, the dll1_config.h.in will be expanded to real dll1_config.h. targets add its directory path to include_directories and refer to that header config file in its source/header files.

Printer is independent target just like dll2's Logger. Printer also exports and has package config and version file.

Now head to 'util/cmakelists.txt', this file defines Util target as a shared library. it links to Printer optionally and always links to package Logger in dll2. The link to Printer is local (same as in Part 1) so don't use find_package(). The link to Logger is external because Logger is defined in other root so we have to first import the Logger (by calling find_package()) then link to it. and that's enough for Util to build. when install, Util first install its artifacts then optionally Printer's artifacts then the imported Logger's artifacts. Since Logger is imported, it doesnot have any install rules like install(target Logger ..) or any COMPONENT associated with it. We have to get Logger's properties (which is set in Logger's package config file), those properties contain path to Logger's runtime/header directories and we install those directories to our install folder. Note that because the Util target will also be exported later, so the install folder of Util should contain simple structure like described at the end of part 1. therefore the Util should copy all needed Logger's header files and runtimes into Util's install folder, then hide Logger package from consumer by defining the link to Logger in BUILD_INTERFACE. it means that the target Logger will not appear on the Util's target export file. (otherwise, the consumer have to not only define path to Util's package config file but also path to Logger's package config file. For non-cmake project that uses Util, setting path to Util's header dir and all Util's dependees header dir is a nightmare).  


Now that dll1 has two exported targets (Util and Printer). dll1 can write an overal package config file that include those two package config files. consumer of dll1 only find dll1's overal package config file and dll1's package config file will include needed components. at the end of 'dll1/cmakelists.txt' is exporting part of dll1's overal package config file.

And finally, the application. This App1 is an executable linking to local target Lib and external Dll1 library. Lib is static library, nothing special about it. Dll1 is external package so it has to be imported by find_package() first. If dll1 is built with Printer option ON, App1 can specify 'COMPONENTS Util Printer' in find_package() to make sure Util and Printer are available and links to them. That's all to build App1. When install App1, remember to copy all dll1's runtimes into same folder as App1.exe.

 
build & install:

go to 'dll2' folder and open terminal then type:
build.bat
(or cmake -P run.cmake)

go to 'dll1' folder and open terminal then type:
build.bat
(or cmake -P run.cmake)

go to 'app' folder and open terminal then type:
build.bat
(or cmake -P run.cmake)

