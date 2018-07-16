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
