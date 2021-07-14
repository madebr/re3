include(FindPkgConfig REQUIRED)
pkg_check_modules(CRASHPAD REQUIRED IMPORTED_TARGET breakpad-client)

find_program(CRASHPAD_DUMP_SYMS_PROGRAM dump_syms)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CrashpadSupport
    REQUIRED_VARS CRASHPAD_DUMP_SYMS_PROGRAM
)

if(NOT TARGET Crashpad::client)
    add_library(Crashpad::client INTERFACE IMPORTED)
    set_target_properties(Crashpad::client
        PROPERTIES
            INTERFACE_LINK_LIBRARIES "PkgConfig::CRASHPAD"
    )
endif()
