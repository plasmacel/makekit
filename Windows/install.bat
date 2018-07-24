@echo off

set DEFAULT_CMAKE_INSTALL=C:\Program Files\CMake
set DEFAULT_LLVM_INSTALL=C:\Program Files\LLVM
set DEFAULT_MAKEKIT_INSTALL=C:\Program Files\MakeKit

:: Get latest installed Windows 10 SDK version

call %~dp0\winsdk_version.bat WINSDK_VER

:: Get installation directories from user input

:: set /p WINSDK_VER=Windows SDK Version (default is %WINSDK_VER%):
set /p CMAKE_INSTALL=CMake installation directory (default is %DEFAULT_CMAKE_INSTALL%):
if "%CMAKE_INSTALL%" == "" (
	set CMAKE_INSTALL=%DEFAULT_CMAKE_INSTALL%
)
if not exist "%CMAKE_INSTALL%" (
	echo ERROR: CMake installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

set /p LLVM_INSTALL=LLVM installation directory (default is %DEFAULT_LLVM_INSTALL%):
if "%LLVM_INSTALL%" == "" (
	set LLVM_INSTALL=%DEFAULT_LLVM_INSTALL%
)
if not exist "%LLVM_INSTALL%" (
	echo ERROR: LLVM installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit
)

set /p MAKEKIT_INSTALL=MakeKit installation directory (default is %DEFAULT_MAKEKIT_INSTALL%):
if "%MAKEKIT_INSTALL%" == "" (
	set MAKEKIT_INSTALL=%DEFAULT_MAKEKIT_INSTALL%
)
if not exist "%MAKEKIT_INSTALL%" (
	mkdir "%MAKEKIT_INSTALL%\bin"
)

:: Set dependency path variables

set VCVARS_DIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build
set WINSDK_DIR=C:\Program Files (x86)\Windows Kits\10\bin\%WINSDK_VER%\x64
set CMAKE_BIN=%CMAKE_INSTALL%\bin
set LLVM_BIN=%LLVM_INSTALL%\bin
set LLVM_LIB=%LLVM_INSTALL%\lib
set MAKEKIT_BIN=%MAKEKIT_INSTALL%\bin

:: Set environment variables

echo Setting required environment variables...

setx MAKEKIT_CMAKE_BIN "%CMAKE_BIN:\=/%"
setx MAKEKIT_LLVM_DIR "%LLVM_INSTALL:\=/%"
setx MAKEKIT_LLVM_BIN "%LLVM_BIN:\=/%"
setx MAKEKIT_LLVM_LIB "%LLVM_LIB:\=/%"

PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%VCVARS_DIR%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%WINSDK_DIR%"

PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%CMAKE_BIN%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%LLVM_BIN%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%LLVM_LIB%"
PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\addpath.ps1" "%MAKEKIT_BIN%"

:: Copying files

echo Copying files to %MAKEKIT_BIN%...
copy "%~dp0\ninja\ninja.exe" "%MAKEKIT_BIN%\ninja.exe"
copy "%~dp0\mk.bat" "%MAKEKIT_BIN%\mk.bat"
copy "%~dp0\mk_clean.bat" "%MAKEKIT_BIN%\mk_clean.bat"
copy "%~dp0\mk_config.bat" "%MAKEKIT_BIN%\mk_config.bat"
copy "%~dp0\mk_make.bat" "%MAKEKIT_BIN%\mk_make.bat"
copy "%~dp0\mk_reconfig.bat" "%MAKEKIT_BIN%\mk_reconfig.bat"
copy "%~dp0\mk_refresh.bat" "%MAKEKIT_BIN%\mk_refresh.bat"
copy "%~dp0\mk_remake.bat" "%MAKEKIT_BIN%\mk_remake.bat"

echo Done.
set /p dummy=Press ENTER...
@echo on
