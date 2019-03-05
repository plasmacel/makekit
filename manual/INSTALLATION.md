## I. Installation

### Dependencies

MakeKit depends on CMake and Ninja, so you have to install them before installing MakeKit.

### Windows

1. Download and install the latest version (3.12 or above is required) of CMake:
   https://cmake.org/download
2. Download the binary distribution of Ninja (if unavailable, then build it from source):
   https://github.com/ninja-build/ninja/releases
3. Run `install.bat` as administrator, or open command prompt as administrator, navigate to its directory and use command `install`.
   
 ### macOS
 
 1. Download and install the latest version (3.12 or above is required) of CMake:
   https://cmake.org/download
 2. Run `install`. This will install all up-to-date required packages.
   
 ### Linux
 
 *Currently only Debian based systems (like Debian, Raspbian, Ubuntu) are supported!*
 
 1. Download and install the latest version (3.12 or above is required) of CMake:
   https://cmake.org/download
 2. Run `install`. This will install all up-to-date required packages.
    
## I. LLVM toolchain development environments

**Darwin / macOS**

On Darwin based systems (including macOS) LLVM completely replaces the Apple LLVM (Apple's fork or LLVM) and GNU C/C++ toolchains. Targeting native platform, `clang` should be ran with argument `--driver-mode=gcc` for C, and `--driver-mode=g++` for C++ compilation.

- Assembler: `llvm-as`
- C Compiler: `clang --driver-mode=gcc` or simply `clang`
- C++ compiler: `clang --driver-mode=g++` or simply `clang++`
- Library tool: `llvm-lib`
- Linker: `lld -flavor darwin`, or simply `ld.lld`

**Linux**

On Linux systems LLVM completely replaces the GNU C/C++ toolchain. Targeting native platform, `clang` should be ran with argument `--driver-mode=gcc` for C, and `--driver-mode=g++` for C++ compilation.

GNU Toolchain

- Assembler: `as`
- C Compiler: `gcc`
- C++ compiler: `g++`
- Library tool: `lib`
- Linker: `lld -flavor darwin`, or simply `ld.lld`

- Archiver tool: `ar`
- Diff tool: `diff`
- Library indexer: `ranlib`
- Viewer: `nm`

LLVM Toolchain

- Assembler: `llvm-as`
- C Compiler: `clang --driver-mode=gcc` or simply `clang`
- C++ compiler: `clang --driver-mode=g++` or simply `clang++`
- Library tool: `llvm-lib`
- Linker: `lld -flavor gnu`, or simply `ld.lld`
- Resource Compiler: `llvm-rc`

- Archiver tool: `llvm-ar`
- Diff tool: `llvm-diff`
- Viewer: `llvm-nm`
- Indexer: `llvm-ranlib`

**Windows**

On Windows systems LLVM almost completely replaces the Visual C++ tolchain, but still requires the [Microsoft Resource Compiler (RC)](https://docs.microsoft.com/en-us/windows/desktop/menurc/resource-compiler) `rc.exe` from the Windows SDK, and the [Microsoft Assembler (MASM)](https://docs.microsoft.com/en-us/cpp/assembler/masm/masm-for-x64-ml64-exe) `ml64.exe` from the Visual Studio Build Tools. Targeting native platform, `clang` should be ran with argument `--driver-mode=cl` both for C and C++ compilation. LLVM also provides an alternative executable `clang-cl` for this behavior.

MSVC Toolchain

- Assembler: `ml64`
- Compiler: `cl`
- Library tool: `lib`
- Linker: `link`
- Manifest tool: `mt`
- Resource Compiler: `rc`

LLVM Toolchain

- Assembler/Disassembler: integrated, can be invoked as standalone by `llvm-mc`
- Compiler: `clang --driver-mode=cl`, or equivalently `clang-cl`
- Library tool: `llvm-lib`
- Linker: `lld -flavor link`, or equivalently `lld-link`
- Manifest tool: `llvm-mt`
- Resource Compiler: `llvm-rc`

Static library tools
- Archiver tool: `llvm-ar`
- Indexer tool: `llvm-ranlib`

Binary object tools
- Diff tool: `llvm-diff`
- Viewer tool: `llvm-nm`

More info: https://clang.llvm.org/docs/UsersManual.html#clang-cl

Still, if a MinGW-w64 toolchain is required for some reason, MakeKit is able to seamlessly integrate with it (**I/B**). In this case `clang` can be used just like on Unix/Linux systems, i.e. use it like `clang --driver-mode=gcc` for C, and `clang --driver-mode=g++` for C++ compilation.

1. Download and install the latest stable binary distribution of LLVM/clang for your OS:
    http://releases.llvm.org

##### I/A Visual C++ development environment toolchain using LLVM/clang (Windows)

1. If you already have **Visual Studio 2017** installed on your computer, then go to the next step. Otherwise, download and install Microsoft's **Build Tools for Visual Studio 2017**.
   It will install all the required tools to build applications, but without the Visual Studio IDE. At the installer options don't forget to check-in the option to also install the latest Windows 10 SDK.
   https://go.microsoft.com/fwlink/?linkid=840931 or https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017
2. Download and install the latest stable binary distribution of LLVM/clang for your OS:
   http://releases.llvm.org

##### I/B MSYS2 MinGW-w64 (GNU for Windows) development environment with LLVM/clang toolchain

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
10. (Optional) Install the required libraries using the package manager:
   `pacman -Sy mingw-w64-x86_64-boost`
   `pacman -Sy mingw-w64-x86_64-qt5`

- More info https://medium.com/audelabs/c-development-using-visual-studio-code-cmake-and-lldb-d0f13d38c563

## II. Environment Variables

MakeKit relies on the following environment variables, which are automatically created at its install:

- `MK_DIR` - The installation directory of MakeKit, where its `bin` folder can be found
- `MK_LLVM_DIR` - The installation directory of LLVM, where its `bin` and `lib` folders can be found
- `MK_BOOST_DIR` - The installation directory of the desired version of Boost, where its `bin` and `lib` folders can be found
- `MK_QT_DIR` - The installation directory of the desired version of Qt, where its `bin` and `lib` folders can be found
- `MK_QT_QMLDIR` - The installation directory of the desired version of Qt QML library (usually it's `MK_QT_DIR/qml`.
