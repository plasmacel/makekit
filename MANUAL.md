### `mk config BUILD_TYPE`

Creates a build system configuration for the specified `BUILD_TYPE`. If a build system has been already configured, then updates it. This command is mandatory when files has been added or removed from the source.

### `mk refresh BUILD_TYPE`

Alias for `mk config BUILD_TYPE`

### mk reconfig BUILD_TYPE

Removes the current configuration and creates a new one for the specified `BUILD_TYPE`.

### mk make BUILD_TYPE

Invokes a
Refreshes the generated build system and starts a build.

### mk remake BUILD_TYPE

Removes all prebuilt binaries of the specified configuration and rebuilds them.

### mk clean BUILD_TYPE

Removes the build directory of the configuration specified by `BUILD_TYPE`.
