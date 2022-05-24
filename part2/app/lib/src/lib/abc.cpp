
#include "lib/abc.h"
#include <stdio.h>

namespace lib {
	void abcWrite(const char* str) {

		const char* platformName = "win32";
		#ifdef LIB_X64
		platformName = "x64"; 
		#endif
		const char* configName = "debug";
		#ifdef LIB_RELEASE
		configName = "release";
		#endif
		printf("Lib: %s, %s\n", platformName, configName);

		printf(str);
	}
}

