# MakeKit

MakeKit is a collection of CMake files, integration tools and step-by-step guides to make the cross-platform compilation of modern C/C++ simple. With the proper CMake files you can build your project on wide variety of platforms and compilers, while using an arbitrary IDE. MakeKit also helps to integrate your IDE with the CMake build system.

MakeKit is strictly relies on the CMake build system, Ninja build generator, and the LLVM/clang compiler infrastructure to achieve:

- Support of cross-platform compilation of modern C/C++
- Support of parallel technologies like OpenMP, OpenCL and CUDA
- Support of the cross-platform windowing framework Qt

**The project is at a very early stage, so if you find any issue or you could simply add something, please contribute.**

# I. CMake with Ninja Generator

### Windows

1. Download and install the latest version (3.10 or above is required) of CMake
   https://cmake.org
2. Download and install the binary distribution of Ninja (if unavailable, then build it from the source)
   https://ninja-build.org
   https://github.com/ninja-build/ninja/releases
   
### macOS using Homebrew

1. Install CMake and Ninja with command line
`brew install cmake`
`brew install ninja`

### Ubuntu/Debian

1. Install CMake and Ninja with command line
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

1. Install CLion
   https://www.jetbrains.com/clion
2. Perform the steps in **MSYS2 MinGW-w64 toolchain with LLVM/clang**
3. Open CLion and navigate to `File -> Settings -> Build, Execution, Deployment -> Toolchains`
4. For the option `Environment` select `MinGW`
5. Now the compiler should auto-detect the paths of the required components.
   If they are detected, then proceed to the next steps and check your settings, otherwise you should set them manually.
6. The `Make` field should be set to the path `C:\msys64\mingw64\bin\mingw32-make.exe`
7. The `C Compiler` field should set to the path `C:\msys64\mingw64\bin\clang.exe`
8. The `C++ Compiler` field should set to the path `C:\msys64\mingw64\bin\clang++.exe`
9. The `Debugger` option should be set to `MinGW-w64 GDB (C:\msys64\mingw64\bin\gdb.exe)`
10. Navigate to `File -> Settings -> Build, Execution, Deployment -> CMake`
11. Now create your target profiles (build types) like `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel`, with the following options\
12. The `CMake options` field should begin with `-GNinja`
12. The `Environment` field should contain `CC=C:\msys64\mingw64\bin\clang.exe;CXX=C:\msys64\mingw64\bin\clang++.exe`
13. The `Build options` field should be set to `-j 8` to take advantage of multiple cores
14. Create a new project by `File -> New Project...` and copy `CMakeLists.txt` to the project folder

### Visual Studio (Windows, macOS)

1. Download and install Visual Studio from the link https://visualstudio.microsoft.com or https://visualstudio.microsoft.com/vs/features/cplusplus
    Don't forget to check the `Visual C++ tools for CMake` component under the `Individual components` tab at the installation
2. Perform the steps in **Visual C++ toolchain with LLVM/clang (clang-cl)**
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

### Code::Blocks (Windows, macOS, Linux)

TODO

### Sublime Text (Windows, macOS, Linux)

.TODO

### Xcode (macOS)

TODO

# III Toolchains and compilers

1. Download and install the latest stable binary distribution of LLVM/clang for your OS:
    http://releases.llvm.org
2. (Optional) Download and install Qt for your compiler infrastructure
    https://www.qt.io/download

**Alternatively, you can also install LLVM/clang the following ways:**

##### MSYS2 MinGW-w64 with LLVM/clang for Windows

1. Download and install the x86_64 MSYS2 toolchain package of MinGW-w64 from the link
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
    
##### LLVM/clang for macOS
Install the latest version of LLVM/clang with Homebrew:
`brew install --with-toolchain llvm`
    
##### LLVM/clang for Linux
Install the latest version of clang with command line:
`sudo apt install clang`

- More info https://medium.com/audelabs/c-development-using-visual-studio-code-cmake-and-lldb-d0f13d38c563
