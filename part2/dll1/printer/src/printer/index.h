

#include "dll1_config.h"
#ifdef DLL1_PRINTER_ENABLED


#ifndef DLL1_PRINTER_H
#define DLL1_PRINTER_H

#if defined(_WIN32)
#  if defined(DLL1_PRINTER_EXPORT)
#    define DLL1_PRINTER_API __declspec(dllexport)
#  else
#    define DLL1_PRINTER_API __declspec(dllimport)
#  endif
#else // non windows
#  define DLL1_PRINTER_API
#endif


namespace dll1 {
	void DLL1_PRINTER_API printer_do(const char* str);
}

#endif // DLL1_PRINTER_H

#endif // DLL1_PRINTER_ENABLED


