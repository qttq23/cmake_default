
#include "dll2/calculator.h"
#include <stdio.h>

namespace dll2 {
	int add(int a, int b) {

		const char* platformName = "win32";
		#ifdef DLL2_X64
		platformName = "x64"; 
		#endif
		const char* configName = "debug";
		#ifdef DLL2_RELEASE
		configName = "release";
		#endif
		printf("Dll2: %s, %s\n", platformName, configName);

		lib3::write("call lib3 from dll2\n");
		
		return a + b;	// warning: maybe overflow
	}
}