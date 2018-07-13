@echo off
call %~dp0\winsdk_version.bat WINSDK_VER

set DEFAULT_CMAKE_INSTALL=C:\Program Files\CMake
set DEFAULT_LLVM_INSTALL=C:\Program Files\LLVM

REM set /p WINSDK_VER=Windows SDK Version (default is %WINSDK_VER%):
set /p CMAKE_INSTALL=LLVM installation directory (default is %DEFAULT_CMAKE_INSTALL%):
if not exist "%CMAKE_INSTALL%" (
	echo ERROR: CMake installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

set /p LLVM_INSTALL=LLVM installation directory (default is %DEFAULT_LLVM_INSTALL%):
if not exist "%LLVM_INSTALL%" (
	echo ERROR: LLVM installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

echo %LLVM_INSTALL%

REM Set dependency path variables
set VCVARS_DIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build
set WINSDK_DIR=C:\Program Files (x86)\Windows Kits\10\bin\%WINSDK_VER%\x64
set CMAKE_DIR=%CMAKE_INSTALL%\bin
set LLVM_DIR=%LLVM_INSTALL%\bin

echo Adding the required dependencies to user PATH...

PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%VCVARS_DIR%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%WINSDK_DIR%"

PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%CMAKE_DIR%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%LLVM_DIR%"

echo Done.
set /p dummy=Press ENTER...
@echo on
exit
