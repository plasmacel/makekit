## Generate `CMakeLists.txt` files

MakeKit automatically generates `CMakeLists.txt` files for your project using a wide variety of user-specified settings.

TODO

## Create a build system configuration (and execute it)

The flow of the build process is the following: MakeKit first generates a Ninja build system using CMake (`mk config`), then this build system is being executed in parallelized, concurrent fashion (`mk make`), where each build task will use the LLVM compiler (clang) and linker (lld). The generated build system can be updated (`mk_refresh`) and re-generated (`mk reconfig`) any time. Similarly, the built binaries can be re-built (`mk remake`) any time. Also, if required, all generated files, including the build system and the built binaries can be removed (`mk clean`). 

To build a source with the pre-generated `CMakeLists.txt` file(s), open the command line terminal, navigate to the source directory and use `mk make BUILD_TYPE`. If you want to create a build system configuration without executing it, use `mk config BUILD_TYPE` instead. Later, you can execute it by `mk make BUILD_TYPE`.

## Adding/removing files from the source

Using the auto-generated `CMakeLists.txt` of MakeKit, when you create or refresh a build configuration, CMake will automatically find and register files in your source directory, including:

- header files (`.h`, `.hh`, `.hpp`, `.hxx`)
- inline files (`.inc`, `.inl`, `.ipp`, `.ixx`, `.tcc`, `.tpp`, `.txx`)
- source files (`.c`, `.cc`, `.cpp`, `.cxx`)
- Qt user interface files (`.ui`)
- pre-built binary object files (`.o`, `.obj`)
- assembler files (`.asm`, `.s`)
- CUDA source files (`.cu`)

If the source tree has been changed by adding or removing files, existing build configurations should be updated to correctly reflect the changes by `mk config BUILD_TYPE` or `mk refresh BUILD_TYPE`. Note, that `mk make BUILD_TYPE` automatically performs this refresh.

## Build types

Currently the following `BUILD_TYPE` values are available:

- `debug` - Debug
- `release` - Release
- `release-debuginfo` - RelWithDebInfo, i.e. Release with debug information
- `release-minsize` - MinSizeRel, i.e. Release with minimal binary size

## Commands

#### `mk clean BUILD_TYPE`

Removes the directory (including all associated files) of the build configuration specified by `BUILD_TYPE`.

#### `mk config BUILD_TYPE`

Creates a build system configuration for the specified `BUILD_TYPE`. If it has been already created, then this command will refresh it. This command is also required when files has been added or removed from the source.

#### `mk make BUILD_TYPE`

Creates or refreshes the build configuration specified by `BUILD_TYPE` and executes it, i.e. it starts the build process.

#### `mk reconfig BUILD_TYPE`

Removes the build configuration of the specified `BUILD_TYPE` and re-creates it from scratch. This command is recommended if `CMakeLists.txt` has been changed.

#### `mk refresh BUILD_TYPE`

Alias for `mk config BUILD_TYPE`.

#### `mk remake BUILD_TYPE`

Removes all prebuilt binaries of the build configuration specified by `BUILD_TYPE` and rebuilds them.
