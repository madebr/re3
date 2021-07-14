find_package(CrashpadSupport REQUIRED)

function(crashpad_create_symbol_file TARGET)
    cmake_parse_arguments(CCS "INSTALL" "INSTALL_ROOT" "" ${ARGN})
    if(NOT CCS_INSTALL_ROOT)
        set(CCS_INSTALL_ROOT "symbols")
    endif()
    set(symbol_file_path "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.sym")
    if(MSVC)
        set(dump_syms_input $<TARGET_PDB_FILE:${TARGET}>)
    else()
        set(dump_syms_input $<TARGET_FILE:${TARGET}>)
    endif()
    add_custom_command(
        OUTPUT "${symbol_file_path}"
        COMMAND ${CRASHPAD_DUMP_SYMS_PROGRAM} ${dump_syms_input} >"${symbol_file_path}"
        DEPENDS ${TARGET}
    )
    add_custom_target(create_${TARGET}_symbol ALL
        DEPENDS "${symbol_file_path}"
    )
    install(CODE "
        # Read first line of symbol and convert to list
        file(STRINGS \"${symbol_file_path}\" SYMBOL_FILE_HEADER LIMIT_COUNT 1)
        string(REGEX REPLACE \"[ ]+\" \";\" SYMBOL_FILE_HEADER \"\${SYMBOL_FILE_HEADER}\")
        list(LENGTH SYMBOL_FILE_HEADER HEADER_LENGTH)
        if(NOT HEADER_LENGTH EQUAL 5)
            message(FATAL_ERROR \"Header of symbol does not contain 5 items (\${SYMBOL_FILE_HEADER})\")
        endif()
        # Extract hash and name of module line
        list(GET SYMBOL_FILE_HEADER 3 MODULE_HASH)
        list(GET SYMBOL_FILE_HEADER 4 MODULE_NAME)

        # symbol destination
        set(destdir \"\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${CCS_INSTALL_ROOT}/\${MODULE_NAME}/\${MODULE_HASH}\")
        # Create directory + copy symbol file
        execute_process(
            COMMAND \"\${CMAKE_COMMAND}\" -E make_directory \"\${destdir}\"
        )
        message(STATUS \"Installing: \${destdir}/\${MODULE_NAME}.sym\")
        execute_process(
            COMMAND \"\${CMAKE_COMMAND}\" -E copy_if_different \"${symbol_file_path}\" \"\${destdir}/\${MODULE_NAME}.sym\"
        )
    ")
endfunction()
