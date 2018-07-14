@echo off
set BUILD_TYPE="Release"

if "%1" == "debug" (
	set BUILD_TYPE="Debug"
) else if "%1" == "debuginfo" (
	set BUILD_TYPE="RelWithDebInfo"
) else if "%1" == "release" (
	set BUILD_TYPE="Release"
) else if "%1" == "releasemin" (
	set BUILD_TYPE="RelMinSize"
)

:: Enter execution directory
cd %~dp0

:: Delete build directory if exists
if exist "build\" (
	echo "Deleting previous build directory..."
	@RD /S /Q "build"
)

:: Set environment variables for x64
call vcvars64.bat

:: Run CMake
cmake %~dp0 -G "Ninja" -Bbuild -DCMAKE_C_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_CXX_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_LINKER="%MAKEKIT_LLVM_BIN%/lld-link.exe" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"

set /p dummy=Press ENTER...
@echo on