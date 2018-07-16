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
:: cd %~dp0

:: Set environment variables for x64
if not "%VSCMD_ARG_TGT_ARCH%" == "x64" (
	if not "%VSCMD_ARG_HOST_ARCH%" == "x64" (
		call vcvars64.bat
	)
)

:: Run CMake
echo Configuring %1 build...
cmake . -G "Ninja" -Bbuild_%1 -DCMAKE_C_COMPILER:PATH="clang-cl.exe" -DCMAKE_CXX_COMPILER:PATH="clang-cl.exe" -DCMAKE_LINKER:PATH="lld-link.exe" -DCMAKE_RC_COMPILER:PATH="rc.exe" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"
:: cmake %~dp0 -G "Ninja" -Bbuild_%1 -DCMAKE_C_COMPILER:PATH="clang-cl.exe" -DCMAKE_CXX_COMPILER:PATH="clang-cl.exe" -DCMAKE_LINKER:PATH="lld-link.exe" -DCMAKE_RC_COMPILER:PATH="rc.exe" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"
:: cmake %~dp0 -G "Ninja" -Bbuild_%1 -DCMAKE_TOOLCHAIN_FILE="MakeKitToolchain.cmake" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"

@echo on
