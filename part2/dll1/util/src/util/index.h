

#ifndef DLL1_UTIL_H
#define DLL1_UTIL_H

#if defined(_WIN32)
#  if defined(DLL1_UTIL_EXPORT)
#    define DLL1_UTIL_API __declspec(dllexport)
#  else
#    define DLL1_UTIL_API __declspec(dllimport)
#  endif
#else // non windows
#  define DLL1_UTIL_API
#endif


// optional printer
#include "dll1_config.h"
#ifdef DLL1_PRINTER_ENABLED
	#include "printer/index.h"
#endif

#include "logger/index.h"


namespace dll1 {
	void DLL1_UTIL_API util_do();
}

#endif // DLL1_UTIL_H
