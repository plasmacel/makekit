@echo off

set COMMAND=%1
set BUILD_TYPE=%2

if "%ARG2%" == "debug" (
	set BUILD_TYPE="Debug"
) else if "%ARG2%" == "debuginfo" (
	set BUILD_TYPE="RelWithDebInfo"
) else if "%ARG2%" == "release" (
	set BUILD_TYPE="Release"
) else (
	set BUILD_TYPE=""
)

if "%COMMAND%" == "make" (
	:: Make
	cd %~dp0
	if exist "build\" (
		echo "Deleting previous build directory..."
		@RD /S /Q "build"
	)
	call vcvars64.bat
	cmake %~dp0 -G "Ninja" -Bbuild -DCMAKE_C_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_CXX_COMPILER="%MAKEKIT_LLVM_BIN%/clang-cl.exe" -DCMAKE_LINKER="%MAKEKIT_LLVM_BIN%/lld-link.exe" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%"
	set /p dummy=Press ENTER...
) else (
	if "%COMMAND%" == "" (
		echo No command specified.
	) else (
		echo Invalid command "%COMMAND%".
	)
)

@echo on