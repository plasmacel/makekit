## VIII. Troubleshooting

TODO

1. Check the required applications and their versions.
2. Check the required environment variables and `PATH`.
3. Check whether the source tree is free of in-source build files.
4. Check the required libraries of your project and their location.
5. Check the required user and access permissions.

### Configuration errors

#### **CMakes gives errors about a path that is cannot be found**

Check whether the path is existing and valid, then check the required `MK_*` environment variables incuding `PATH`.

#### **CMake gives errors about missing libraries or they are cannot be found**

Check the actual location and version of the libraries used in your project.

### Linker errors

#### **The linker gives errors about multiple definitions**

Check whether the source tree is free of in-source build files, since this error is very common if the source tree is polluted by pre-built binaries.

#### **The linker gives errors about missing entry points**

Please check the type of your targets, since this error indicates that you probably added something as an `EXECUTABLE` which doesn't have an `int main()` function or an equivalent alternative. Did you add a library as an `EXECUTABLE`?
