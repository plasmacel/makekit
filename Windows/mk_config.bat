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
if exist "build_%1\" (
	echo "Deleting previous build directory..."
	@RD /S /Q "build_%1"
)

:: Set environment variables for x64
if not "%VSCMD_ARG_TGT_ARCH%" == "x64" (
	if not "%VSCMD_ARG_HOST_ARCH%" == "x64" (
		call vcvars64.bat
	)
)

:: Run CMake
echo Configuring %1 build...
cmake %~dp0 -G "Ninja" -Bbuild_%1 -DCMAKE_C_COMPILER:PATH="clang-cl.exe" -DCMAKE_CXX_COMPILER:PATH="clang-cl.exe" -DCMAKE_LINKER:PATH="lld-link.exe" -DCMAKE_RC_COMPILER:PATH="rc.exe" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"
:: cmake %~dp0 -G "Ninja" -Bbuild_%1 -DCMAKE_C_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_CXX_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_LINKER="%MAKEKIT_LLVM_BIN%/lld-link.exe" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"
:: cmake %~dp0 -G "Ninja" -Bbuild -DCMAKE_TOOLCHAIN_FILE="MakeKitToolchain.cmake" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"

@echo on
