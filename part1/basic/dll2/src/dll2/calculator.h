

#ifndef DLL2_CALCULATOR_H
#define DLL2_CALCULATOR_H

#if defined(_WIN32)
#  if defined(DLL2_EXPORT)
#    define DLL2_CALCULATOR_API __declspec(dllexport)
#  else
#    define DLL2_CALCULATOR_API __declspec(dllimport)
#  endif
#else // non windows
#  define DLL2_CALCULATOR_API
#endif

#include "lib3/logger.h"

namespace dll2 {
	int DLL2_CALCULATOR_API add(int a, int b);
}

#endif

