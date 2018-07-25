# MakeKit CMake file for custom build types
# Keep in mind, that CMake BUILD_TYPEs are case-insensitive, thus
# it doesn't make difference between lowercase and uppercase characters.
# The following build type names are protected by CMake: None, Debug, Release, RelWithDebInfo, MinSizeRel.
# You can inherit from another build types by listing their flags variable (like ${CMAKE_CXX_FLAGS_DEBUG}) in your custom flags.

message("Adding custom build types...")

# MYCUSTOM : Rename MYCUSTOM to anything but the protected names!

set(CMAKE_CXX_FLAGS_MYCUSTOM "${CMAKE_CXX_FLAGS_DEBUG} -Wall -Wpedantic"
    CACHE STRING "Flags used by the C++ compiler during MYCUSTOM builds."
    FORCE)

set(CMAKE_C_FLAGS_MYCUSTOM "${CMAKE_C_FLAGS_DEBUG} -Wall -Wpedantic"
    CACHE STRING "Flags used by the C compiler during MYCUSTOM builds."
    FORCE)

set(CMAKE_EXE_LINKER_FLAGS_MYCUSTOM
    ""
    CACHE STRING "Flags used for linking binaries during MYCUSTOM builds."
    FORCE)

set(CMAKE_SHARED_LINKER_FLAGS_MYCUSTOM
    ""
    CACHE STRING "Flags used by the shared libraries linker during MYCUSTOM builds."
    FORCE)

mark_as_advanced(
    CMAKE_CXX_FLAGS_MYCUSTOM
    CMAKE_C_FLAGS_MYCUSTOM
    CMAKE_EXE_LINKER_FLAGS_MYCUSTOM
    CMAKE_SHARED_LINKER_FLAGS_MYCUSTOM)

# Update the documentation string of CMAKE_BUILD_TYPE for GUIs
set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}"
    CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel MYCUSTOM."
    FORCE)

# Add further build types here...
