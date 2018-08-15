# Manual

- I. [**Installation**](https://github.com/plasmacel/makekit/blob/master/manual/INSTALLATION.md)
- II. [**Integration**](https://github.com/plasmacel/makekit/blob/master/manual/INTEGRATION.md)
- III. [**MakeKit CLI**](https://github.com/plasmacel/makekit/blob/master/manual/COMMANDS.md)
- IV. Usage
- V. Generate `CMakeLists.txt`
- VI. The make process
- VII. [**Troubleshooting**](https://github.com/plasmacel/makekit/blob/master/manual/TROUBLESHOOTING.md)


## IV. The build (err, make) process

The flow of the build process is the following: MakeKit first generates a Ninja build system using CMake (`mk config`), then this build system is being executed in parallelized, concurrent fashion (`mk make`), where each build task will use the LLVM C/C++ compiler (clang) and linker (lld). The generated build system can be updated (`mk refresh`) and re-generated (`mk reconfig`) any time. Similarly, the built binaries can be re-built (`mk remake`) any time. If required, all generated files, including the build system and the built binaries can be permanently removed (`mk clean`).

To build a source with the pre-generated `CMakeLists.txt` file(s), open the command line terminal, navigate to the source directory and use `mk make BUILD_TYPE`. If you want to create a build system configuration without executing it, use `mk config BUILD_TYPE` instead. Later, you can execute it by `mk make BUILD_TYPE`.

## V. Adding/removing files from the source

Using the auto-generated `CMakeLists.txt` of MakeKit, when you create or refresh a build configuration, CMake will automatically find and register files in your source directory, including:

- header files (`.h`, `.h++`, `.hh`, `.hpp`, `.hxx`)
- inline files (`.inc`, `.inl`, `.i++`, `.icc`, `.ipp`, `.ixx`, `.t++`, `.tcc`, `.tpp`, `.txx`)
- source files (`.c`, `.c++`, `.cc`, `.cpp`, `.cxx`)
- Qt resource files (`.qrc`)
- Qt user interface files (`.ui`)
- pre-built binary object files (`.o` on macOS & Linux, `.obj` on Windows)
- assembler files (`.asm`, `.s`)
- CUDA source files (`.cu`)

If the source tree has been changed by adding or removing files, existing build configurations should be updated to reflect these changes by `mk refresh BUILD_TYPE`. Note, that `mk make BUILD_TYPE -R` automatically performs this refresh.


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

