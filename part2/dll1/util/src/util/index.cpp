

#include "util/index.h"
#include "dll1_config.h"
#include <stdio.h>


namespace dll1 {
	void util_do() {

		// optional printer
		#ifdef DLL1_PRINTER_ENABLED
			dll1::printer_do("hello from util\n");
		#else
			printf("hello from util - not printer\n");
		#endif
		
		logger::write("call logger from util\n");

	}
}



