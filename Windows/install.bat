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

REM Set dependency path variables
set VCVARS_DIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build
set WINSDK_DIR=C:\Program Files (x86)\Windows Kits\10\bin\%WINSDK_VER%\x64
set CMAKE_BIN=%CMAKE_INSTALL%\bin
set LLVM_BIN=%LLVM_INSTALL%\bin

echo Installing Ninja...

copy "%~dp0\ninja\ninja.exe" "%CMAKE_BIN%\ninja.exe"

echo Adding required environment variables...

setx MAKEKIT_CMAKE_BIN "%CMAKE_BIN:\=/%"
setx MAKEKIT_LLVM_BIN "%LLVM_BIN:\=/%"

echo Adding required dependencies to user PATH...

PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%VCVARS_DIR%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%WINSDK_DIR%"

PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%CMAKE_BIN%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%LLVM_BIN%"

echo Done.
set /p dummy=Press ENTER...
@echo on
