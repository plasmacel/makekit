# IDE Integration

Thanks to its command line interface, MakeKit can be integrated with any IDE in which custom tasks or external tools are supported.

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

MakeKit provides full integration with Visual Studio 2017.

1. Download and install Visual Studio with `Visual C++ tools for CMake` component (you can select it at the `Individual components` tab in the installer)
    https://visualstudio.microsoft.com or https://visualstudio.microsoft.com/vs/features/cplusplus
2. Perform the steps in guide **III/A**
3. Create a directory for your project and copy the `CMakeLists.txt` and `CMakeSettings.json` files to it.

For more info see https://docs.microsoft.com/en-us/cpp/ide/cmake-tools-for-visual-cpp

Visual Studio integration is based on Visual Studio's [CMake](https://docs.microsoft.com/en-us/cpp/ide/cmake-tools-for-visual-cpp) and ["Open Folder"](https://docs.microsoft.com/en-us/visualstudio/ide/develop-code-in-visual-studio-without-projects-or-solutions) development features. The IDE and its built-in Build/Rebuild/Clean commands can be manipulated by the following files:

- `CMakeSettings.json`
This file is required to make IntelliSense work and to launch builds on a CMake projects. It enables to launch the default Build, Rebuild and Clean commands using CMake.

- `CppProperties.json`
This file is currently not required for MakeKit integration.

- `.vs/launch.vs.json`
This file is optional, and can be used to create custom debug environments.

- `.vs/tasks.vs.json`
This file is required to integrate all features of MakeKit into the Visual Studio IDE. It enables to launch the default Build, Rebuild and Clean commands using MakeKit and spawns context menu items to perform additional MakeKit tasks.

| Visual Studio                                               | CMake Command                                              |
|:------------------------------------------------------------|:-----------------------------------------------------------|
| Solution file (.sln)                                        | project()                                                  |
| Project file (.vcxproj)                                     | target name in the command add_executable or add_library   |
| executable (.exe)                                           | add_executable()                                           |
| static library (.lib)                                       | add_library(STATIC)                                        |
| dynamic library (.dll)                                      | add_library(SHARED)                                        |
| Source Folders                                              | source_group                                               |
| Project Folders                                             | set_property(TARGET PROPERTY FOLDER)                       |
| Properties->General->Output Directory                       | set_target_properties(PROPERTIES RUNTIME_OUTPUT_DIRECTORY) |
| Properties->C/C++->Preprocessor->Preprocessor Definitions   | add_compile_definitions()                                  |
| Properties->C/C++->General->Additional Include Directories  | target_include_directories()                               |
| Properties->Linker->General->Additional Library Directories | link_directories()                                         |
| Properties->Linker->Input->Additional Dependencies          | target_link_libraries()                                    |

#### Known problems

https://developercommunity.visualstudio.com/content/problem/189962/cmake-outputs-broken-source-file-paths-in-build-lo.html
https://developercommunity.visualstudio.com/content/problem/215727/double-click-in-error-list-does-nothing-for-cpp-fi.html

#### More info

- https://cognitivewaves.wordpress.com/cmake-and-visual-studio/
- https://blogs.msdn.microsoft.com/vcblog/2016/10/05/bring-your-c-codebase-to-visual-studio-with-open-folder/
- https://blogs.msdn.microsoft.com/vcblog/2017/11/02/customizing-your-environment-with-visual-c-and-open-folder/

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

### Eclipse CDT (Windows, macOS, Linux)

TODO

### Sublime Text (Windows, macOS, Linux)

TODO

https://nurpax.github.io/posts/2017-01-06-cmake-sublime-text-3.html

### Xcode (macOS)

TODO
