

#ifndef DLL1_PRINTER_H
#define DLL1_PRINTER_H

#if defined(_WIN32)
#  if defined(DLL1_EXPORT)
#    define DLL1_PRINTER_API __declspec(dllexport)
#  else
#    define DLL1_PRINTER_API __declspec(dllimport)
#  endif
#else // non windows
#  define DLL1_PRINTER_API
#endif

#include "dll2/calculator.h"

namespace dll1 {
	void DLL1_PRINTER_API show(const char* msg);
}

#endif

