# MakeKit

MakeKit is a collection of CMake files, integration tools and step-by-step guides to make the cross-platform compilation of modern C/C++ simple. With the proper CMake files you can build your project on wide variety of platforms and compilers, while using an arbitrary IDE. MakeKit also helps to integrate your IDE with the CMake build system.

MakeKit is strictly relies on the CMake build system, Ninja build generator, and the LLVM/clang compiler infrastructure to achieve:

- Support of cross-platform compilation of modern C/C++
- Support of parallel technologies like OpenMP, OpenCL and CUDA
- Support of the cross-platform windowing framework Qt

**The project is at a very early stage, so if you find any issue or you could simply add something, please contribute.**

# I. Install CMake and Ninja

1. Download and install the latest version (3.10 or above is required) of CMake
   https://cmake.org
2. Download and install the binary distribution of Ninja (if unavailable, then build it from the source)
   https://ninja-build.org
   https://github.com/ninja-build/ninja/releases

### Alternative installations

##### CMake and Ninja for macOS using Homebrew
1. Update Homebrew
    `brew update`
    `brew upgrade`
2. Install CMake and Ninja
    `brew install cmake`
    `brew install ninja`

##### Install CMake and Ninja for Ubuntu/Debian with command line
1. Update the package and dependency list:
    `sudo apt update`
    `sudo apt upgrade`
2. Install CMake and Ninja
    `sudo apt install cmake`
    `sudo apt install ninja-build`

- More info
https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
https://gitlab.kitware.com/cmake/community/wikis/FAQ
https://www.johnlamp.net/cmake-tutorial.html
http://lektiondestages.blogspot.com/2017/09/setting-up-qt-5-cmake-project-for.html
https://github.com/boostorg/hana/wiki/Setting-up-Clang-on-Windows
https://metricpanda.com/rival-fortress-update-27-compiling-with-clang-on-windows

# II. Select an IDE

### CLion (Windows, macOS, Linux)

CLion on Windows currently supports the following set of development environments: `MinGW`, `Cygwin`, `WSL` and `Visual Studio`. Unfortunately, debugging is not yet supported with the `Visual Studio` environment. If debugging is required then `MinGW` and `WSL` are recommended. Currently, MakeKit only supports the `MinGW` and `Visual Studio` environments.

- For the `Visual Studio` environment, perform the steps of guide **III/A**.
- For the `MinGW` environment, perform the steps of guide **III/B**.

1. Install CLion
   https://www.jetbrains.com/clion
3. Open CLion and navigate to
   Windows, Linux: `File -> Settings -> Build, Execution, Deployment -> Toolchains`
   macOS: `CLion -> Preferences -> Build, Execution, Deployment -> Toolchains`
4. Windows: For the option `Environment` select `Visual Studio` or `MinGW`. Now CMake should auto-detect the path of the development environment. If they are detected, then proceed to the next step, otherwise you should set them manually. The default path of `Visual Studio` environment is `C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools`, `C:\Program Files (x86)\Microsoft Visual Studio\2017\Community` or `C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise`, while the default path of `MinGW` is `...`.
   macOS, Linux: Proceed to step 9.
5. Now CMake should auto-detect the paths of the required components.
   If they are detected, then proceed to the next step and check your settings, otherwise you should set them manually.
6. The `Make` field should be set to the path or `nmake.exe` or `C:\msys64\mingw64\bin\mingw32-make.exe`
7. The `C Compiler` field should set to the path `C:/Program Files/LLVM/bin/clang-cl.exe` or `C:\msys64\mingw64\bin\clang.exe`
8. The `C++ Compiler` field should set to the path `C:/Program Files/LLVM/bin/clang-cl.exe` or `C:\msys64\mingw64\bin\clang++.exe`
9. The `Debugger` option should be set to `MinGW-w64 GDB (C:\msys64\mingw64\bin\gdb.exe)`
10. Navigate to `File -> Settings -> Build, Execution, Deployment -> CMake`
11. Now create your target profiles (build types) like `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel`, with the following options\
12. The `CMake options` field should begin with `-GNinja`
12. The `Environment` field should contain `CC=C:\msys64\mingw64\bin\clang.exe;CXX=C:\msys64\mingw64\bin\clang++.exe`
13. The `Build options` field should be set to `-j 8` to take advantage of multiple cores
14. Create a new project by `File -> New Project...` and copy `CMakeLists.txt` to the project folder

### Visual Studio (Windows, macOS)

1. Download and install Visual Studio with `Visual C++ tools for CMake` component (you can select it at the `Individual components` tab in the installer)
    https://visualstudio.microsoft.com or https://visualstudio.microsoft.com/vs/features/cplusplus
2. Perform the steps in guide **III/A**
3. Create a directory for your project and copy the `CMakeLists.txt` and `CMakeSettings.json` files to it.

For more info see https://docs.microsoft.com/en-us/cpp/ide/cmake-tools-for-visual-cpp

### Visual Studio Code (Windows, macOS, Linux)

1. Download and install Visual Studio Code from the link
   https://code.visualstudio.com
2. Install the C/C++ extension for Visual Studio Code
   https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools
3. Install the CMake extension for Visual Studio Code
   https://marketplace.visualstudio.com/items?itemName=twxs.cmake
   or the more verbose https://marketplace.visualstudio.com/items?itemName=vector-of-bool.cmake-tools
4. Perform the steps in **MSYS2 MinGW-w64 toolchain with LLVM/clang**
5. Create a directory for your project and copy the `CMakeLists.txt` and `c_cpp_properties.json` to the `.vscode` folder.

This section is still incomplete, TODO

### Code::Blocks (Windows, macOS, Linux)

TODO

### Sublime Text (Windows, macOS, Linux)

.TODO

### Xcode (macOS)

TODO

# III. Development environments and compilers

1. Download and install the latest stable binary distribution of LLVM/clang for your OS:
    http://releases.llvm.org
2. (Optional) Download and install Qt for your compiler infrastructure
    https://www.qt.io/download

### Alternative installations

##### III/A Visual C++ development environment with LLVM/clang for Windows

1. If you already have a Visual Studio 2017 installed on your computer, then go to the next step. Otherwise, download and install Microsoft's **Build Tools for Visual Studio 2017**.
   It will install all the required tools to build applications, including the `cl` compiler, but without the Visual Studio IDE:
   https://go.microsoft.com/fwlink/?linkid=840931 or https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017
2. Download and install the latest stable binary distribution of LLVM/clang for your OS:
   http://releases.llvm.org

##### III/B MSYS2 MinGW-w64 development environment with LLVM/clang for Windows

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
    
##### III/C LLVM/clang for macOS using Homebrew
1. Update Homebrew
    `brew update`
    `brew upgrade`
2. Install the latest version of LLVM/clang
    `brew install --with-toolchain llvm`
    
##### III/D LLVM/clang for Linux using command line
1. Update the package and dependency list:
    `sudo apt update`
    `sudo apt upgrade`
2. Install the latest version of LLVM/clang
    `sudo apt install clang`

- More info https://medium.com/audelabs/c-development-using-visual-studio-code-cmake-and-lldb-d0f13d38c563
