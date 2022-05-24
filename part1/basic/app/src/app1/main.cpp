
#include "lib3/logger.h"
#include "dll2/calculator.h"
#include "dll1/printer.h"
#include <stdio.h>

int main() {

	dll1::show("from main.cpp\n");
	printf("----\n");

	int ret = dll2::add(1, 2);
	printf("----\n");
	
	lib3::write("from main.cpp hello\n");
	printf("----\n");

	return 0;
}