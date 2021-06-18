# MakeKit

**MakeKit is a toolset to make the cross-platform compilation and deployment of modern C/C++ simple.** It relies on the [CMake](https://cmake.org) build system generator, the [Ninja](https://ninja-build.org) build system, and the [LLVM/clang](http://llvm.org) compiler infrastructure to achieve:

- Cross-platform, uniform, out of the box behavior :sparkles:
- Providing simple, low-maintenance build configurations
- Integration with popular integrated development environments (IDEs)
- Support of native and cross compilation of modern C/C++
- Support of parallel technologies OpenMP, OpenCL and CUDA
- Support of graphics APIs OpenGL and Vulkan
- Support of the cross-platform windowing framework Qt 5
- Support of the swiss army knife library Boost

It is composed of two main components: a command line interface (CLI) and a CMake module with many useful commands. Integration tools are also provided to integrate it with your favorite IDE.

**The project is at an early stage, so if you find any issue or you could simply add something, please contribute.**

For usage informations, read the [**manual**](https://github.com/plasmacel/makekit/blob/master/manual/MANUAL.md).

## License

MakeKit is distributed under the [MIT License](https://github.com/plasmacel/makekit/blob/master/LICENSE.txt).
