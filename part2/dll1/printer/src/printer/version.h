
// this file wil be read by cmake.
// don't duplicate line/symbol, don't write comment between symbol and value.
// eg: 
// #define max_abc /*this is used for ...*/ 1000 -> wrong
// #define max_abc 1000 /*this is used for...*/ -> ok

#ifndef DLL1_PRINTER_VERSION_H
#define DLL1_PRINTER_VERSION_H

 
#define DLL1_PRINTER_VERSION    "2.0.0"// this is ok
#define DLL1_PRINTER_VERSION_SO		"2"
#define DLL1_PRINTER_VERSION_MAJOR    "2"
#define DLL1_PRINTER_VERSION_MINOR   "0"


#endif

