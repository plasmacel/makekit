@echo off

set DEFAULT_CMAKE_DIR=%ProgramFiles%\CMake
set DEFAULT_LLVM_DIR=%ProgramFiles%\LLVM
set DEFAULT_MK_DIR=%ProgramFiles%\MakeKit

:: Get CMake installation directory

set /p MK_CMAKE_INSTALL_DIR=CMake installation directory (default is %DEFAULT_CMAKE_DIR%):
if "%MK_CMAKE_INSTALL_DIR%" == "" (
	set MK_CMAKE_INSTALL_DIR=%DEFAULT_CMAKE_DIR%
)
if not exist "%MK_CMAKE_INSTALL_DIR%" (
	echo ERROR: CMake installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit /b 1
)

:: Get LLVM installation directory

set /p MK_LLVM_INSTALL_DIR=LLVM installation directory (default is %DEFAULT_LLVM_DIR%):
if "%MK_LLVM_INSTALL_DIR%" == "" (
	set MK_LLVM_INSTALL_DIR=%DEFAULT_LLVM_DIR%
)
if not exist "%MK_LLVM_INSTALL_DIR%" (
	echo ERROR: LLVM installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit /b 1
)

:: Get MK installation directory

set /p MK_INSTALL_DIR=MakeKit installation directory (default is %DEFAULT_MK_DIR%):
if "%MK_INSTALL_DIR%" == "" (
	set MK_INSTALL_DIR=%DEFAULT_MK_DIR%
)
if exist "%MK_INSTALL_DIR%" (
	echo MakeKit is already installed. Removing previous version...
	rd /s /q "%MK_INSTALL_DIR%"
) else (
	mkdir "%MK_INSTALL_DIR%""
)

:: Get Qt installation directory

set /p MK_QT_INSTALL_DIR=Qt installation directory (optional):
if "%MK_QT_INSTALL_DIR%" == "" (
	echo Qt support disabled.
) else if not exist "%MK_QT_INSTALL_DIR%" (
	echo ERROR: Qt installation directory cannot be found!
	set /p dummy=Press ENTER...
	@echo on
	exit /b 1
)

:: Install Visual Studio 2017 Build Tools
:: https://blogs.msdn.microsoft.com/vcblog/2016/11/16/introducing-the-visual-studio-build-tools/

:: vs_buildtools.exe –quiet –add Microsoft.VisualStudio.Workload.VCTools –includeRecommended

:: Set MK environment variables

set MK_CMAKE_BIN="%MK_CMAKE_INSTALL_DIR%\bin"
set MK_LLVM_BIN="%MK_LLVM_INSTALL_DIR%\bin"
set MK_BIN="%MK_INSTALL_DIR%\bin"

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

:: Check required components

echo.
echo Checking the presence of CMake...
where /q cmake
if %ERRORLEVEL% == 0 (
	echo CMake is OK!
) else (
	echo Error: CMake cannot be found in PATH!
	exit /b 1
)

echo Checking the presence of Ninja...
where /q ninja
if %ERRORLEVEL% == 0 (
	echo Ninja is OK!
) else (
	echo Error: Ninja cannot be found in PATH!
	exit /b 1
)

:: Building source

echo.
echo Building source...

cd "%~dp0\..\.."
::cmake . -GNinja -Bbuild -DCMAKE_BUILD_TYPE=Release
::cmake . -G "Ninja" -Bbuild -DCMAKE_C_COMPILER:FILEPATH="clang-cl" -DCMAKE_CXX_COMPILER:FILEPATH="clang-cl" -DCMAKE_LINKER:FILEPATH="lld-link" -DCMAKE_RC_COMPILER:FILEPATH="rc" -DCMAKE_BUILD_TYPE="Release"
::cmake --build --config Release

::if %ERRORLEVEL% == 0 (
::	echo Build configuration succeeded.
::) else (
::	echo Error: Build configuration failed!
::	exit /b 1
::)

::ninja -C build
mkdir build && mkdir build\bin
clang-cl /nologo /EHsc /MD /O2 /Ob2 /DNDEBUG src/mk.cpp /o build\bin\
clang-cl /nologo /EHsc /MD /O2 /Ob2 /DNDEBUG src/llvm-rc-rc.cpp /o build\bin\

if %ERRORLEVEL% == 0 (
	echo Build succeeded.
) else (
	echo Error: Build failed!
	exit /b 1
)

:: Copying files

echo.
echo Copying files to "%MK_INSTALL_DIR%"...

xcopy /E /F /Y /R "%~dp0\..\..\build\bin" "%MK_INSTALL_DIR%\bin\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

xcopy /E /F /Y /R "%~dp0\vswhere.exe" "%MK_INSTALL_DIR%\bin\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

xcopy /E /F /Y /R "%~dp0\..\..\cmake" "%MK_INSTALL_DIR%\cmake\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

xcopy /E /F /Y /R "%~dp0\..\..\integration" "%MK_INSTALL_DIR%\integration\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

xcopy    /F /Y /R "%~dp0\..\..\LICENSE.txt" "%MK_INSTALL_DIR%\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

:: Removing files

echo.
echo Removing temporary files...
rd /s /q "%~dp0\..\..\build"

echo Installation done.
set /p dummy=Press ENTER...

@echo on
exit /b 0
