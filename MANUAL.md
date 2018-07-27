# Manual

## Environment Variables

MakeKit relies on the following environment variables, which are automatically created at its install:

- `MAKEKIT_DIR` - The installation directory of MakeKit, where its `bin` folder can be found
- `MAKEKIT_LLVM_DIR` - The installation directory of LLVM, where its `bin` and `lib` folders can be found
- `MAKEKIT_QT_DIR` - The installation directory of the desired version of Qt, where its `bin` and `lib` folders can be found

## Generate and customize `CMakeLists.txt` files

MakeKit automatically generates `CMakeLists.txt` files for your project using a wide variety of user-specified settings.

TODO

| VARIABLE         | Description    | Value type          |
|:-----------------|:---------------|:--------------------|
| `MK_ASM`         | ASM support    | `BOOL`              |
| `MK_CUDA`        | CUDA support   | `BOOL`              |
| `MK_OPENCL`      | OpenCL support | `BOOL`              |
| `MK_OPENGL`      | OpenGL support | `BOOL`              |
| `MK_OPENMP`      | OpenMP support | `BOOL`              |
| `MK_VULKAN`      | Vulkan support | `BOOL`              |
| `MK_QT`          | Qt 5 support   | `QT_LIST`           |
| `MK_MODULE_MODE` | Target type    | `TARGET`            |

#### Accepted values

**Type `BOOL`**

`TRUE` (or alternatively `ON` `YES` `Yes` `yes` `Y` `y` `1`)
`FALSE` (or alternatively `OFF` `NO` `No` `no` `N` `n` `0`)

**Type `TARGET`**

`NONE`
`EXECUTABLE`
`STATIC_LIBRARY`
`SHARED_LIBRARY`

**Type `QT_LIST`**

`OFF`, or a list of the following values:

`Bluetooth`
`Charts`
`Concurrent`
`Core`
`DataVisualization`
`DBus`
`Designer`
`Gamepad`
`Gui`
`Help`
`LinguistTools`
`Location`
`MacExtras`
`Multimedia`
`MultimediaWidgets`
`Network`
`NetworkAuth`
`Nfc`
`OpenGL`
`OpenGLExtensions`
`Positioning`
`PositioningQuick`
`PrintSupport`
`Purchasing`
`Qml`
`Quick`
`QuickCompiler`
`QuickControls2`
`QuickTest`
`QuickWidgets`
`RemoteObjects`
`RepParser`
`Script`
`ScriptTools`
`Scxml`
`Sensors`
`SerialBus`
`SerialPort`
`Sql`
`Svg`
`Test`
`TextToSpeech`
`UiPlugin`
`UiTools`
`WebChannel`
`WebEngine`
`WebEngineCore`
`WebEngineWidgets`
`WebSockets`
`WebView`
`Widgets`
`Xml`
`XmlPatterns`
`3DAnimation`
`3DCore`
`3DExtras`
`3DInput`
`3DLogic`
`3DQuick`
`3DQuickAnimation`
`3DQuickExtras`
`3DQuickInput`
`3DQuickRender`
`3DQuickScene2D`
`3DRender`

More info: http://doc.qt.io/qt-5/qtmodules.html

### CMakeLists.txt commands

**`mk_add_imported_library(NAME MODE INCLUDE_DIRECTORY STATIC_IMPORT SHARED_IMPORT)`**

Add an imported library using the name `NAME`.

**`mk_deploy()`**

Perform post-build deploy to the runtime output directory (`bin`).

**`mk_deploy_list()`**

Generate a `.txt` file containing the required deploy files into the target build directories.

## Create a build system configuration (and execute it)

The flow of the build process is the following: MakeKit first generates a Ninja build system using CMake (`mk config`), then this build system is being executed in parallelized, concurrent fashion (`mk make`), where each build task will use the LLVM C/C++ compiler (clang) and linker (lld). The generated build system can be updated (`mk refresh`) and re-generated (`mk reconfig`) any time. Similarly, the built binaries can be re-built (`mk remake`) any time. If required, all generated files, including the build system and the built binaries can be permanently removed (`mk clean`).

To build a source with the pre-generated `CMakeLists.txt` file(s), open the command line terminal, navigate to the source directory and use `mk make BUILD_TYPE`. If you want to create a build system configuration without executing it, use `mk config BUILD_TYPE` instead. Later, you can execute it by `mk make BUILD_TYPE`.

## Adding/removing files from the source

Using the auto-generated `CMakeLists.txt` of MakeKit, when you create or refresh a build configuration, CMake will automatically find and register files in your source directory, including:

- header files (`.h`, `.hh`, `.hpp`, `.hxx`)
- inline files (`.inc`, `.inl`, `.ipp`, `.ixx`, `.tcc`, `.tpp`, `.txx`)
- source files (`.c`, `.cc`, `.cpp`, `.cxx`)
- Qt user interface files (`.ui`)
- pre-built binary object files (`.o` on macOS & Linux, `.obj` on Windows)
- assembler files (`.asm`, `.s`)
- CUDA source files (`.cu`)

If the source tree has been changed by adding or removing files, existing build configurations should be updated to reflect these changes by `mk config BUILD_TYPE` or `mk refresh BUILD_TYPE`. Note, that `mk make BUILD_TYPE` automatically performs this refresh.

## Build types

All default CMake `BUILD_TYPE`s are available:

| BUILD_TYPE                         | Description                                       | clang flags       | clang-cl flags                     |
|:-----------------------------------|:--------------------------------------------------|:------------------|:-----------------------------------|
| None                               |                                                   |                   | `/DWIN32 /D_WINDOWS /W3 /GR /EHsc` |
| Debug (debug)                      | Debug build, no optimization                      | `-g`              | `/MDd /Zi /Ob0 /Od /RTC1`          |
| Release (release)                  | Release build, full optimization                  | `-O3 -DNDEBUG`    | `/MD /O2 /Ob2 /DNDEBUG`            |
| RelWithDebInfo (release-debuginfo) | Release build, optimization with debug symbols    | `-O2 -g -DNDEBUG` | `/MD /Zi /O2 /Ob1 /DNDEBUG`        |
| MinSizeRel (release-minsize)       | Release build, optimization for small binary size | `-Os -DNDEBUG`    | `/MD /O1 /Ob1 /DNDEBUG`            |


Custom build types are also available and can be configured in `CustomBuilds.cmake`.

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
