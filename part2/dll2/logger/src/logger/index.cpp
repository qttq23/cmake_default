

#include "logger/index.h"
#include <stdio.h>

namespace logger {
	void write(const char* str) {
		
		const char* platformName = "win32";
		#ifdef LOGGER_X64
		platformName = "x64"; 
		#endif
		const char* configName = "debug";
		#ifdef LOGGER_RELEASE
		configName = "release";
		#endif
		printf("logger: %s, %s\n", platformName, configName);

		printf(str);
	}
}

