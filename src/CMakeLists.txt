set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

file(GLOB_RECURSE REVC_SOURCES "*.cpp" "*.h" "*.rc")

function(header_directories RETURN_LIST)
    file(GLOB_RECURSE ALL_SRCS *.h *.cpp *.c)
    set(RELDIRS)
    foreach(SRC ${ALL_SRCS})
        file(RELATIVE_PATH RELSRC "${CMAKE_CURRENT_SOURCE_DIR}" "${SRC}")
        get_filename_component(RELDIR "${RELSRC}" DIRECTORY)
        list(APPEND RELDIRS ${RELDIR})
    endforeach()
    list(REMOVE_DUPLICATES RELDIRS)
    set(${RETURN_LIST} ${RELDIRS} PARENT_SCOPE)
endfunction()

header_directories(REVC_INCLUDES)

add_executable(reVC WIN32
    ${REVC_SOURCES}
)

target_link_libraries(reVC PRIVATE
    librw::librw
    Threads::Threads
)

target_include_directories(reVC
    PRIVATE
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${REVC_INCLUDES}>
)

target_compile_definitions(reVC
    PRIVATE
        $<IF:$<CONFIG:DEBUG>,DEBUG,NDEBUG>
        LIBRW
        REVC_NO_AUTOLINK
)

if(LIBRW_PLATFORM_D3D9)
    target_compile_definitions(reVC
        PUBLIC
            USE_D3D9
    )
endif()

if(REVC_AUDIO STREQUAL "OAL")
    find_package(OpenAL REQUIRED)
    target_include_directories(reVC PRIVATE ${OPENAL_INCLUDE_DIR})
    target_link_libraries(reVC PRIVATE ${OPENAL_LIBRARY})
    target_compile_definitions(reVC PRIVATE ${OPENAL_DEFINITIONS})
    target_compile_definitions(reVC PRIVATE AUDIO_OAL)
elseif(REVC_AUDIO STREQUAL "MSS")
    find_package(MilesSDK REQUIRED)
    target_compile_definitions(reVC PRIVATE AUDIO_MSS)
    target_link_libraries(reVC PRIVATE MilesSDK::MilesSDK)
endif()

if(REVC_WITH_OPUS)
    find_package(opusfile REQUIRED)
    target_link_libraries(reVC PRIVATE
        opusfile::opusfile
    )
    target_compile_definitions(reVC PRIVATE AUDIO_OPUS)
else()
    find_package(mpg123 REQUIRED)
    find_package(SndFile REQUIRED)
    target_link_libraries(reVC PRIVATE
        MPG123::libmpg123
        SndFile::SndFile
    )
endif()

target_compile_definitions(reVC PRIVATE )

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    target_compile_options(reVC
        PRIVATE
            "-Wall"
    )
    if (NOT LIBRW_PLATFORM_PS2)
        target_compile_options(reVC
            PRIVATE
                -Wextra
                -Wdouble-promotion
                -Wpedantic
        )
    endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    target_compile_options(reVC
        PUBLIC
            /Zc:sizedDealloc-
    )
endif()

set_target_properties(reVC
    PROPERTIES
        C_STANDARD 11
        C_EXTENSIONS OFF
        C_STANDARD_REQUIRED ON
        CXX_STANDARD 11
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
)

if(REVC_INSTALL)
    install(
        TARGETS reVC
        EXPORT reVC-targets
        RUNTIME DESTINATION "."
    )
    if(MSVC)
        install(FILES $<TARGET_PDB_FILE:reVC> DESTINATION "." OPTIONAL)
    endif()
endif()
