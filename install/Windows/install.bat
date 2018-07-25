@echo off

set DEFAULT_CMAKE_DIR=C:\Program Files\CMake
set DEFAULT_LLVM_DIR=C:\Program Files\LLVM
set DEFAULT_MAKEKIT_DIR=C:\Program Files\MakeKit

:: Get latest installed Windows 10 SDK version

call %~dp0\win10sdk_version.bat WINSDK_VER

:: Get installation directories from user input

:: set /p WINSDK_VER=Windows SDK Version (default is %WINSDK_VER%):
set /p CMAKE_DIR=CMake installation directory (default is %DEFAULT_CMAKE_DIR%):
if "%CMAKE_DIR%" == "" (
	set CMAKE_DIR=%DEFAULT_CMAKE_DIR%
)
if not exist "%CMAKE_DIR%" (
	echo ERROR: CMake installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

set /p LLVM_DIR=LLVM installation directory (default is %DEFAULT_LLVM_DIR%):
if "%LLVM_DIR%" == "" (
	set LLVM_DIR=%DEFAULT_LLVM_DIR%
)
if not exist "%LLVM_DIR%" (
	echo ERROR: LLVM installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

set /p MAKEKIT_DIR=MakeKit installation directory (default is %DEFAULT_MAKEKIT_DIR%):
if "%MAKEKIT_DIR%" == "" (
	set MAKEKIT_DIR=%DEFAULT_MAKEKIT_DIR%
)
if not exist "%MAKEKIT_DIR%" (
	mkdir "%MAKEKIT_DIR%\bin"
)

set /p QT_DIR=Qt installation directory:
if "%QT_DIR%" == "" (
	set QT_DIR=%DEFAULT_QT_DIR%
)
if not exist "%QT_DIR%" (
	echo ERROR: Qt installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

:: Set dependency path variables

set VCVARS_DIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build
set WINSDK_DIR=C:\Program Files (x86)\Windows Kits\10\bin\%WINSDK_VER%\x64

set CMAKE_BIN=%CMAKE_DIR%\bin
set LLVM_BIN=%LLVM_DIR%\bin
set LLVM_LIB=%LLVM_DIR%\lib
set MAKEKIT_BIN=%MAKEKIT_DIR%\bin

:: Set environment variables

echo Setting required environment variables...

:: Create MAKEKIT environment variables
call %~dp0\export.bat "MAKEKIT_DIR" "%MAKEKIT_DIR:\=/%"
call %~dp0\export.bat "MAKEKIT_LLVM_DIR" "%LLVM_DIR:\=/%"
call %~dp0\export.bat "MAKEKIT_QT_DIR" "%QT_DIR:\=/%"

:: Add required directories to the PATH

call %~dp0\export.bat "PATH" "%VCVARS_DIR%"
call %~dp0\export.bat "PATH" "%WINSDK_DIR%"
call %~dp0\export.bat "PATH" "%CMAKE_BIN%"
call %~dp0\export.bat "PATH" "%LLVM_BIN%"
call %~dp0\export.bat "PATH" "%LLVM_LIB%"
call %~dp0\export.bat "PATH" "%MAKEKIT_BIN%"

:: Copying files

echo Installing LLVM OpenMP (libomp) to %LLVM_DIR%...

copy "%~dp0\deps\llvm-openmp\include\omp.h" "%LLVM_DIR%\lib\clang\6.0.0\include\omp.h"

copy "%~dp0\deps\llvm-openmp\bin\libomp.dll" "%LLVM_DIR%\bin\libomp.dll"
copy "%~dp0\deps\llvm-openmp\bin\libompd.dll" "%LLVM_DIR%\bin\libompd.dll"

copy "%~dp0\deps\llvm-openmp\lib\libomp.lib" "%LLVM_DIR%\lib\libomp.lib"
copy "%~dp0\deps\llvm-openmp\lib\libompd.lib" "%LLVM_DIR%\lib\libompd.lib"

echo Copying files to %MAKEKIT_DIR%...

mkdir "%MAKEKIT_DIR%"
xcopy /s "%~dp0\bin" "%MAKEKIT_DIR%\bin"
xcopy /s "%~dp0\cmake" "%MAKEKIT_DIR%\cmake"
xcopy /s "%~dp0\integration" "%MAKEKIT_DIR%\integration"

:: copy "%~dp0\mk.bat" "%MAKEKIT_BIN%\mk.bat"
:: copy "%~dp0\mk_clean.bat" "%MAKEKIT_BIN%\mk_clean.bat"
:: copy "%~dp0\mk_config.bat" "%MAKEKIT_BIN%\mk_config.bat"
:: copy "%~dp0\mk_make.bat" "%MAKEKIT_BIN%\mk_make.bat"
:: copy "%~dp0\mk_reconfig.bat" "%MAKEKIT_BIN%\mk_reconfig.bat"
:: copy "%~dp0\mk_refresh.bat" "%MAKEKIT_BIN%\mk_refresh.bat"
:: copy "%~dp0\mk_remake.bat" "%MAKEKIT_BIN%\mk_remake.bat"

echo Done.
set /p dummy=Press ENTER...
@echo on
