# Manual

## I. Installation

### Windows

1. Download and install the latest version (3.10 or above is required) of CMake
   https://cmake.org/download
2. Download the binary distribution of Ninja (if unavailable, then build it from source)
   https://github.com/ninja-build/ninja/releases
3. Run `install.bat` as administrator, or open command prompt as administrator, navigate to its directory and use command `install`.
   
 ### macOS
 
 1. Download and install the latest version (3.10 or above is required) of CMake
   https://cmake.org/download
 2. Run `install`.
   
 ### Linux
 
 *Currently only Debian Linux is supported!*
 
 1. Download and install the latest version (3.10 or above is required) of CMake
   https://cmake.org/download
 2. Run `install`.

##### Install CMake and Ninja for Ubuntu/Debian using command line
1. Update the package and dependency list:
    `sudo apt update`
    `sudo apt upgrade`
2. Install CMake and Ninja
    `sudo apt install cmake`
    `sudo apt install ninja-build`
    
## I. Development environments and compilers

1. Download and install the latest stable binary distribution of LLVM/clang for your OS:
    http://releases.llvm.org

##### I/A Visual C++ development environment with LLVM/clang on Windows

1. If you already have Visual Studio 2017 installed on your computer, then go to the next step. Otherwise, download and install Microsoft's **Build Tools for Visual Studio 2017**.
   It will install all the required tools to build applications, including the `cl` compiler, but without the Visual Studio IDE:
   https://go.microsoft.com/fwlink/?linkid=840931 or https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017
2. Download and install the latest stable binary distribution of LLVM/clang for your OS:
   http://releases.llvm.org

##### I/B MSYS2 MinGW-w64 development environment with LLVM/clang on Windows

1. Download and install the **x86_64 MSYS2** toolchain package of **MinGW-w64**:
   MSYS2: http://www.msys2.org, mingw-64: http://mingw-w64.org/doku.php
2. Launch the MSYS2 terminal from the Start Menu
3. Update the package database and core system packages with command:
   `pacman -Syu`
4. If needed, close MSYS2, run it again and update the rest with command:
   `pacman -Su`
5. Install GIT
   `pacman -Sy git`
   `pacman -S mingw-w64-x86_64-git`
6. Install make and cmake with command:
   `pacman -Sy make`
   `pacman -Sy cmake`
   `pacman -S mingw-w64-x86_64-make`
   `pacman -S mingw-w64-x86_64-cmake mingw-w64-x86_64-extra-cmake-modules`
7. Instal GDB (GNU Debugger) with command:
   `pacman -S mingw-w64-x86_64-gdb`
8. Install the x86_64 version of LLVM/clang with command:
   `pacman -S mingw-w64-x86_64-llvm mingw-w64-x86_64-clang`
9. Install the preferred toolchain with command:
   `pacman -S mingw-w64-x86_64-toolchain`
10. (Optional) Install Qt 5 if required with command:
   `pacman -Sy mingw-w64-x86_64-qt5`
    
##### I/C LLVM/clang for macOS using Homebrew
1. Update Homebrew
    `brew update`
    `brew upgrade`
2. Install the latest version of LLVM/clang
    `brew install --with-toolchain llvm`
    
##### I/D LLVM/clang for Linux using command line
1. Update the package and dependency list:
    `sudo apt update`
    `sudo apt upgrade`
2. Install the latest version of LLVM/clang
    `sudo apt install clang`

- More info https://medium.com/audelabs/c-development-using-visual-studio-code-cmake-and-lldb-d0f13d38c563

## II. Environment Variables

MakeKit relies on the following environment variables, which are automatically created at its install:

- `MAKEKIT_DIR` - The installation directory of MakeKit, where its `bin` folder can be found
- `MAKEKIT_LLVM_DIR` - The installation directory of LLVM, where its `bin` and `lib` folders can be found
- `MAKEKIT_QT_DIR` - The installation directory of the desired version of Qt, where its `bin` and `lib` folders can be found

## III. Generate and customize `CMakeLists.txt`

MakeKit automatically generates `CMakeLists.txt` files for your project using a wide variety of user-specified settings.

TODO

| VARIABLE         | Description    | Value type          |
|:-----------------|:---------------|:--------------------|
| `MK_ASM`         | ASM support    | `BOOL`              |
| `MK_BOOST`       | Boost support  | `BOOST_LIST`        |
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

**Type `BOOST_LIST`**

`OFF`, or a list of the following values:

`accumulators`
`algorithm`
`align`
`any`
`array`
`asio`
`assert`
`assign`
`atomic`
`beast`
`bimap`
`bind`
`callable_traits`
`chrono`
`circular_buffer`
`compatibility`
`compute`
`concept_check`
`config`
`container`
`container_hash`
`context`
`contract`
`conversion`
`convert`
`core`
`coroutine`
`coroutine2`
`crc`
`date_time`
`detail`
`disjoint_sets`
`dll`
`dynamic_bitset`
`endian`
`exception`
`fiber`
`filesystem`
`flyweight`
`foreach`
`format`
`function`
`function_types`
`functional`
`fusion`
`geometry`
`gil`
`graph`
`graph_parallel`
`hana`
`heap`
`hof`
`icl`
`integer`
`interprocess`
`intrusive`
`io`
`iostreams`
`iterator`
`lambda`
`lexical_cast`
`local_function`
`locale`
`lockfree`
`log`
`logic`
`math`
`metaparse`
`move`
`mp11`
`mpi`
`mpl`
`msm`
`multi_array`
`multi_index`
`multiprecision`
`numeric`
`optional`
`parameter`
`phoenix`
`poly_collection`
`polygon`
`pool`
`predef`
`preprocessor`
`process`
`program_options`
`property_map`
`property_tree`
`proto`
`ptr_container`
`python`
`qvm`
`random`
`range`
`ratio`
`rational`
`regex`
`scope_exit`
`serialization`
`signals`
`signals2`
`smart_ptr`
`sort`
`spirit`
`stacktrace`
`statechart`
`static_assert`
`system`
`test`
`thread`
`throw_exception`
`timer`
`tokenizer`
`tti`
`tuple`
`type_erasure`
`type_index`
`type_traits`
`typeof`
`units`
`unordered`
`utility`
`uuid`
`variant`
`vmd`
`wave`
`winapi`
`xpressive`
`yap`

More info: https://www.boost.org/doc/libs/1_67_0

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

## IV. Create a build system configuration (and execute it)

The flow of the build process is the following: MakeKit first generates a Ninja build system using CMake (`mk config`), then this build system is being executed in parallelized, concurrent fashion (`mk make`), where each build task will use the LLVM C/C++ compiler (clang) and linker (lld). The generated build system can be updated (`mk refresh`) and re-generated (`mk reconfig`) any time. Similarly, the built binaries can be re-built (`mk remake`) any time. If required, all generated files, including the build system and the built binaries can be permanently removed (`mk clean`).

To build a source with the pre-generated `CMakeLists.txt` file(s), open the command line terminal, navigate to the source directory and use `mk make BUILD_TYPE`. If you want to create a build system configuration without executing it, use `mk config BUILD_TYPE` instead. Later, you can execute it by `mk make BUILD_TYPE`.

## V. Adding/removing files from the source

Using the auto-generated `CMakeLists.txt` of MakeKit, when you create or refresh a build configuration, CMake will automatically find and register files in your source directory, including:

- header files (`.h`, `.h++`, `.hh`, `.hpp`, `.hxx`)
- inline files (`.inc`, `.inl`, `.i++`, `.icc`, `.ipp`, `.ixx`, `.t++`, `.tcc`, `.tpp`, `.txx`)
- source files (`.c`, `.c++`, `.cc`, `.cpp`, `.cxx`)
- Qt user interface files (`.ui`)
- pre-built binary object files (`.o` on macOS & Linux, `.obj` on Windows)
- assembler files (`.asm`, `.s`)
- CUDA source files (`.cu`)

If the source tree has been changed by adding or removing files, existing build configurations should be updated to reflect these changes by `mk config BUILD_TYPE` or `mk refresh BUILD_TYPE`. Note, that `mk make BUILD_TYPE` automatically performs this refresh.

## VI. Build types

All default CMake `BUILD_TYPE`s are available:

| BUILD_TYPE                         | Description                                       | clang flags       | clang-cl flags                     |
|:-----------------------------------|:--------------------------------------------------|:------------------|:-----------------------------------|
| None                               |                                                   |                   | `/DWIN32 /D_WINDOWS /W3 /GR /EHsc` |
| Debug (debug)                      | Debug build, no optimization                      | `-g`              | `/MDd /Zi /Ob0 /Od /RTC1`          |
| Release (release)                  | Release build, full optimization                  | `-O3 -DNDEBUG`    | `/MD /O2 /Ob2 /DNDEBUG`            |
| RelWithDebInfo (release-debuginfo) | Release build, optimization with debug symbols    | `-O2 -g -DNDEBUG` | `/MD /Zi /O2 /Ob1 /DNDEBUG`        |
| MinSizeRel (release-minsize)       | Release build, optimization for small binary size | `-Os -DNDEBUG`    | `/MD /O1 /Ob1 /DNDEBUG`            |


Custom build types are also available and can be configured in `CustomBuilds.cmake`.

## VII. Commands

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

## VIII. Troubleshooting

TODO

1. Check the required applications and their versions.
2. Check the required environment variables and `PATH`.
3. Check whether the source tree is free of in-source build files.
4. Check the required libraries of your project and their location.
5. Check the required user and access permissions.

## IX. Misc

- https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
- https://gitlab.kitware.com/cmake/community/wikis/FAQ
- https://www.johnlamp.net/cmake-tutorial.html
- http://lektiondestages.blogspot.com/2017/09/setting-up-qt-5-cmake-project-for.html
- https://github.com/boostorg/hana/wiki/Setting-up-Clang-on-Windows
- https://metricpanda.com/rival-fortress-update-27-compiling-with-clang-on-windows

- http://mariobadr.com/creating-a-header-only-library-with-cmake.html
- https://rix0r.nl/blog/2015/08/13/cmake-guide/
- https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1
- http://blog.audio-tk.com/2015/09/01/sorting-source-files-and-projects-in-folders-with-cmake-and-visual-studioxcode/
