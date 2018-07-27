# MakeKit

**MakeKit is a tool to make the cross-platform compilation of modern C/C++ simple.** It relies on the [CMake](https://cmake.org) build system generator, the [Ninja](https://ninja-build.org) build system, and the [LLVM/clang](http://llvm.org) compiler infrastructure to achieve:

- Cross-platform, uniform, out of the box behavior :sparkles:
- Providing simple, low-maintenance build configurations
- Integration with popular integrated development environments (IDEs)
- Support of cross-platform compilation of modern C/C++
- Support of parallel technologies OpenMP, OpenCL and CUDA
- Support of graphics APIs OpenGL and Vulkan
- Support of the cross-platform windowing framework Qt 5
- Support of the swiss army knife library Boost

**The project is at an early stage, so if you find any issue or you could simply add something, please contribute.**

For usage informations, read the [manual](https://github.com/plasmacel/makekit/blob/master/MANUAL.md).

- More info
https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
https://gitlab.kitware.com/cmake/community/wikis/FAQ
https://www.johnlamp.net/cmake-tutorial.html
http://lektiondestages.blogspot.com/2017/09/setting-up-qt-5-cmake-project-for.html
https://github.com/boostorg/hana/wiki/Setting-up-Clang-on-Windows
https://metricpanda.com/rival-fortress-update-27-compiling-with-clang-on-windows

http://mariobadr.com/creating-a-header-only-library-with-cmake.html
https://rix0r.nl/blog/2015/08/13/cmake-guide/
https://gist.github.com/mbinna/c61dbb39bca0e4fb7d1f73b0d66a4fd1
http://blog.audio-tk.com/2015/09/01/sorting-source-files-and-projects-in-folders-with-cmake-and-visual-studioxcode/

# III. Development environments and compilers

1. Download and install the latest stable binary distribution of LLVM/clang for your OS:
    http://releases.llvm.org
2. (Optional) Download and install Qt for your compiler infrastructure
    https://www.qt.io/download

### Alternative installations

##### III/A Visual C++ development environment with LLVM/clang on Windows

1. If you already have Visual Studio 2017 installed on your computer, then go to the next step. Otherwise, download and install Microsoft's **Build Tools for Visual Studio 2017**.
   It will install all the required tools to build applications, including the `cl` compiler, but without the Visual Studio IDE:
   https://go.microsoft.com/fwlink/?linkid=840931 or https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017
2. Download and install the latest stable binary distribution of LLVM/clang for your OS:
   http://releases.llvm.org

##### III/B MSYS2 MinGW-w64 development environment with LLVM/clang on Windows

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
