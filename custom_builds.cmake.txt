# MakeKit CMake file for custom build types
# Keep in mind, that CMake BUILD_TYPEs are case-insensitive, thus
# it doesn't make difference between lowercase and uppercase characters.
# The following build type names are protected by CMake: None, Debug, Release, RelWithDebInfo, MinSizeRel
# You can inherit from another build types by listing their flags variable (like ${CMAKE_CXX_FLAGS_DEBUG}) in your custom flags.

message("Adding custom build types...")

# MYCUSTOM : Rename MYCUSTOM to anything but the protected names!

set(CMAKE_CXX_FLAGS_MYCUSTOM
    "${CMAKE_CXX_FLAGS_DEBUG} -Wpedantic"
    STRING "Flags used by the C++ compiler during MYCUSTOM builds."
)

set(CMAKE_C_FLAGS_MYCUSTOM
    "${CMAKE_C_FLAGS_DEBUG} -Wpedantic"
    STRING "Flags used by the C compiler during MYCUSTOM builds."
)

set(CMAKE_EXE_LINKER_FLAGS_MYCUSTOM
    ""
    STRING "Flags used for linking binaries during MYCUSTOM builds."
)

set(CMAKE_SHARED_LINKER_FLAGS_MYCUSTOM
    ""
    STRING "Flags used by the shared libraries linker during MYCUSTOM builds."
)

mark_as_advanced(
    CMAKE_CXX_FLAGS_MYCUSTOM
    CMAKE_C_FLAGS_MYCUSTOM
    CMAKE_EXE_LINKER_FLAGS_MYCUSTOM
    CMAKE_SHARED_LINKER_FLAGS_MYCUSTOM
)

# Add further build types here...
