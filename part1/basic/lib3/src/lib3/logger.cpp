
#include "lib3/logger.h"
#include <stdio.h>

namespace lib3 {
	void write(const char* str) {
		
		const char* platformName = "win32";
		#ifdef LIB3_X64
		platformName = "x64"; 
		#endif
		const char* configName = "debug";
		#ifdef LIB3_RELEASE
		configName = "release";
		#endif
		printf("Lib3: %s, %s\n", platformName, configName);

		printf(str);
	}
}

