
#include "lib/abc.h"

#include "dll1_config.h"
#include "util/index.h"

#ifdef DLL1_PRINTER_ENABLED
	#include "printer/index.h"
#endif


int main() {

	lib::abcWrite("from main.cpp\n");

	dll1::util_do();

	#ifdef DLL1_PRINTER_ENABLED
		dll1::printer_do("call printer from main\n");
	#endif


	return 0;
}