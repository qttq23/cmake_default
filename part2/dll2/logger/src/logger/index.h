
#ifndef LOGGER_INDEX_H
#define LOGGER_INDEX_H

#if defined(_WIN32)
#  if defined(LOGGER_EXPORT)
#    define LOGGER_API __declspec(dllexport)
#  else
#    define LOGGER_API __declspec(dllimport)
#  endif
#else // non windows
#  define LOGGER_API
#endif

#include "logger/version.h"


namespace logger {
	void LOGGER_API write(const char* str);
}

#endif



