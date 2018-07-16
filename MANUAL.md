## Generate `CMakeLists.txt` files

TODO

## Create a build system configuration and build

To build a source with the proper `CMakeLists.txt` file(s), open the command line terminal, navigate to the source directory and use `mk make BUILD_TYPE`. If you want to create a build system configuration without executing it, use `mk config BUILD_TYPE` instead. Later, you can execute it by `mk make BUILD_TYPE`.

## Adding/removing files from the source

Using the auto-generated `CMakeLists.txt` of MakeKit, when you create or refresh a build configuration, CMake will automatically find and register files in your source directory, including:

- header files (`.h`, `.hh`, `.hpp`, `.hxx`)
- inline files (`.inc`, `.inl`, `.ipp`, `.ixx`)
- source files (`.c`, `.cc`, `.cpp`, `.cxx`)
- Qt user interface files (`.ui`)
- pre-built object files (`.o`, `.obj`)

If the source tree has been changed by adding or removing files, existing build configurations should be updated to correctly reflect the changes by `mk config BUILD_TYPE` or `mk refresh BUILD_TYPE`. Note, that `mk make BUILD_TYPE` automatically performs this refresh.

## Build types

Currently the following build types are evailable:

- `debug` - Debug
- `debuginfo` - RelWithDebInfo, i.e. release with debug information
- `release` - Release
- `releasemin` - MinSizeRel, i.e. release with minimal size

## Commands

#### `mk config BUILD_TYPE`

Creates a build system configuration for the specified `BUILD_TYPE`. If it has been already created, then this command will update it. This command is mandatory when files has been added or removed from the source.

#### `mk refresh BUILD_TYPE`

Alias for `mk config BUILD_TYPE`

#### `mk reconfig BUILD_TYPE`

Removes the build configuration of the specified `BUILD_TYPE` and re-creates it from scratch. This command is recommended if `CMakeLists.txt` has been changed.

#### `mk make BUILD_TYPE`

Creates or refreshes the build configuration specified by `BUILD_TYPE` and executes it, i.e. it starts the build process.

#### `mk remake BUILD_TYPE`

Removes all prebuilt binaries of the build configuration specified by `BUILD_TYPE` and rebuilds them.

#### `mk clean BUILD_TYPE`

Removes the directory (including all associated files) of the build configuration specified by `BUILD_TYPE`.
