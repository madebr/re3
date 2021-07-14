#pragma once

#ifdef CRASH_REPORT
#ifdef _WIN32
# include "client/windows/handler/exception_handler.h"
#elif defined(__APPLE__)
# include "client/mac/handler/exception_handler.h"
#else
# include "client/linux/handler/exception_handler.h"
#endif
#endif

#ifdef _WIN32
#define BREAKPAD_HANDLER(DUMP_PATH) 													\
    google_breakpad::ExceptionHandler breakpad_handler(									\
      /* dump_path */ L".",																\
      filter_callback,																	\
      callback,																			\
      /* context */ nullptr,															\
      google_breakpad::ExceptionHandler::HANDLER_ALL									\
    )
#elif defined(__APPLE__)
#define BREAKPAD_HANDLER(DUMP_PATH) 													\
    google_breakpad::ExceptionHandler breakpad_handler(									\
      callback,																			\
      /* context */ nullptr,															\
      /* install_handler*/ true															\
    )
#else
#define BREAKPAD_HANDLER(DUMP_PATH) 													\
    google_breakpad::MinidumpDescriptor breakpad_handler_descriptor("path/to/cache"); 	\
    google_breakpad::ExceptionHandler breakpad_handler(									\
      breakpad_handler_descriptor,														\
      /* filter */ nullptr,																\
      callback,																			\
      /* context */ nullptr,															\
      /* install handler */ true,														\
      /* server FD */ -1																\
    )
#endif
