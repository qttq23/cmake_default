
#include "dll1/printer.h"
#include <stdio.h>

namespace dll1 {
	void show(const char* msg) {

		const char* platformName = "win32";
		#ifdef DLL1_X64
		platformName = "x64"; 
		#endif
		const char* configName = "debug";
		#ifdef DLL1_RELEASE
		configName = "release";
		#endif
		printf("Dll1: %s, %s\n", platformName, configName);

		int ret = dll2::add(2, 4);
	}
}