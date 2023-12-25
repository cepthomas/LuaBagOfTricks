#ifndef LOGGER_H
#define LOGGER_H

#include <stdio.h>


// Log levels.
typedef enum
{
    LVL_DEBUG = 1,
    LVL_INFO  = 2,
    LVL_ERROR = 3
} log_level_t;


// Initialize the module.
// @param fn File to write to.
// @return Status.
int logger_Init(const char* fn);

// Set log level.
// @param level
// @return Status.
int logger_SetFilters(log_level_t level);

// Log some information. Time stamp is seconds after start, not time of day.
// @param level See log_level_t.
// @param format Format string followed by varargs.
// @return Status.
int logger_Log(log_level_t level, const char* format, ...);

#endif // LOGGER_H
