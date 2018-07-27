@echo off

set DEFAULT_CMAKE_DIR=%ProgramFiles%\CMake
set DEFAULT_LLVM_DIR=%ProgramFiles%\LLVM
set DEFAULT_MAKEKIT_DIR=%ProgramFiles%\MakeKit

:: Get latest installed Windows 10 SDK version

call %~dp0\win10sdk_version.bat WINSDK_VER

:: Get installation directories from user input

:: set /p WINSDK_VER=Windows SDK Version (default is %WINSDK_VER%):
set /p MK_CMAKE_INSTALL_DIR=CMake installation directory (default is %DEFAULT_CMAKE_DIR%):
if "%MK_CMAKE_INSTALL_DIR%" == "" (
	set MK_CMAKE_INSTALL_DIR=%DEFAULT_CMAKE_DIR%
)
if not exist "%MK_CMAKE_INSTALL_DIR%" (
	echo ERROR: CMake installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

set /p MK_LLVM_INSTALL_DIR=LLVM installation directory (default is %DEFAULT_LLVM_DIR%):
if "%MK_LLVM_INSTALL_DIR%" == "" (
	set MK_LLVM_INSTALL_DIR=%DEFAULT_LLVM_DIR%
)
if not exist "%MK_LLVM_INSTALL_DIR%" (
	echo ERROR: LLVM installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

set /p MK_INSTALL_DIR=MakeKit installation directory (default is %DEFAULT_MAKEKIT_DIR%):
if "%MK_INSTALL_DIR%" == "" (
	set MK_INSTALL_DIR=%DEFAULT_MAKEKIT_DIR%
)
if not exist "%MK_INSTALL_DIR%" (
	mkdir "%MK_INSTALL_DIR%\bin"
)

set /p MK_QT_INSTALL_DIR=Qt installation directory:
if "%MK_QT_INSTALL_DIR%" == "" (
	set MK_QT_INSTALL_DIR=%DEFAULT_QT_DIR%
)
if not exist "%MK_QT_INSTALL_DIR%" (
	echo ERROR: Qt installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

:: Set MK environment variables

set MK_CMAKE_BIN=%MK_CMAKE_INSTALL_DIR%\bin
set MK_LLVM_BIN=%MK_LLVM_INSTALL_DIR%\bin
set MK_BIN=%MK_INSTALL_DIR%\bin
:: set WINSDK_DIR=%ProgramFiles(x86)%\Windows Kits\10\bin\%WINSDK_VER%\x64

echo.
echo Creating environment variable MK_VCVARS_DIR...
setx MK_VCVARS_DIR "%VSAPPIDDIR%/../Tools/vsdevcmd\ext"

echo.
echo Creating environment variable MK_DIR...
setx MK_DIR "%MK_INSTALL_DIR:\=/%"

echo.
echo Creating environment variable MK_LLVM_DIR...
setx MK_LLVM_DIR "%MK_LLVM_INSTALL_DIR:\=/%"

echo.
echo Creating environment variable MK_QT_DIR...
setx MK_QT_DIR "%MK_QT_INSTALL_DIR:\=/%"

:: Add required directories to the PATH

echo.
echo Extending environment variable PATH...
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\export_path.ps1" "%MK_CMAKE_BIN%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\export_path.ps1" "%MK_LLVM_BIN%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\export_path.ps1" "%MK_BIN%"

:: Copying files

echo.
echo Installing LLVM OpenMP (libomp) to %MK_LLVM_INSTALL_DIR%...

xcopy /F /Y /R "%~dp0\deps\llvm-openmp\include\omp.h" "%MK_LLVM_INSTALL_DIR%\lib\clang\6.0.0\include\omp.h"

xcopy /F /Y /R "%~dp0\deps\llvm-openmp\bin\libomp.dll" "%MK_LLVM_INSTALL_DIR%\bin\libomp.dll"
xcopy /F /Y /R "%~dp0\deps\llvm-openmp\bin\libompd.dll" "%MK_LLVM_INSTALL_DIR%\bin\libompd.dll"

xcopy /F /Y /R "%~dp0\deps\llvm-openmp\lib\libomp.lib" "%MK_LLVM_INSTALL_DIR%\lib\libomp.lib"
xcopy /F /Y /R "%~dp0\deps\llvm-openmp\lib\libompd.lib" "%MK_LLVM_INSTALL_DIR%\lib\libompd.lib"

echo.
echo Copying files to %MK_INSTALL_DIR%...

xcopy /E /F /Y /R "%~dp0\..\..\bin" "%MK_INSTALL_DIR%\bin"
xcopy /E /F /Y /R "%~dp0\..\..\cmake" "%MK_INSTALL_DIR%\cmake"
xcopy /E /F /Y /R "%~dp0\..\..\integration" "%MK_INSTALL_DIR%\integration"
xcopy    /F /Y /R "%~dp0\..\..\LICENSE.txt" "%MK_INSTALL_DIR%\LICENSE.txt"

echo Done.
set /p dummy=Press ENTER...
@echo on
