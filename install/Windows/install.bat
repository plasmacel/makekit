@echo off

set DEFAULT_CMAKE_DIR=%ProgramFiles%\CMake
set DEFAULT_LLVM_DIR=%ProgramFiles%\LLVM
set DEFAULT_MK_DIR=%ProgramFiles%\MakeKit

echo MakeKit CLI Installer

:: Get CMake installation directory

echo.
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
if exist "%MK_CMAKE_INSTALL_DIR%/bin/cmake.exe" (
	echo CMake found: "%MK_CMAKE_INSTALL_DIR%\bin\cmake.exe"
) else (
	echo Error: CMake cannot be found at "%MK_CMAKE_INSTALL_DIR%/bin/cmake.exe"!
	set /p dummy=Press ENTER...
	exit /b 1
)

:: Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Kitware\CMake :: InstallDir

:: Get LLVM installation directory

echo.
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
if exist "%MK_LLVM_INSTALL_DIR%/bin/clang-cl.exe" (
	echo Clang found: "%MK_LLVM_INSTALL_DIR%\bin\clang-cl.exe"
) else (
	echo Error: Clang cannot be found at "%MK_LLVM_INSTALL_DIR%/bin/clang-cl.exe"!
	set /p dummy=Press ENTER...
	exit /b 1
)

:: Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\LLVM\LLVM :: (Default)

:: Get MK installation directory

echo.
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

echo.
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

echo.
echo Creating environment variable MK_DIR...
setx MK_DIR "%MK_INSTALL_DIR:\=/%"

echo.
echo Creating environment variable MK_TOOLCHAINS_DIR...
setx MK_TOOLCHAINS_DIR "%MK_INSTALL_DIR:\=/%/cmake/toolchains"

echo.
echo Creating environment variable MK_CMAKE...
setx MK_CMAKE "%MK_CMAKE_INSTALL_DIR:\=/%/bin/cmake.exe"

echo.
echo Creating environment variable MK_LLVM_DIR...
setx MK_LLVM_DIR "%MK_LLVM_INSTALL_DIR:\=/%"

echo.
echo Creating environment variable MK_NINJA...
setx MK_NINJA "%MK_INSTALL_DIR:\=/%/bin/ninja.exe"

echo.
echo Creating environment variable MK_QT_DIR...
setx MK_QT_DIR "%MK_QT_INSTALL_DIR:\=/%"

echo.
echo Creating environment variable MK_QT_QMLDIR...
setx MK_QT_QMLDIR "%MK_QT_INSTALL_DIR:\=/%/qml"

:: Building source

echo.
echo Building source...

call %~dp0\vsdevcmd_proxy.bat -arch=x64 -host_arch=x64

cd "%~dp0\..\.."
::cmake . -GNinja -Bbuild -DCMAKE_BUILD_TYPE=Release
::cmake . -G "Ninja" -Bbuild -DCMAKE_C_COMPILER:FILEPATH="clang-cl" -DCMAKE_CXX_COMPILER:FILEPATH="clang-cl" -DCMAKE_BUILD_TYPE="Release"
::cmake --build --config Release

::if %ERRORLEVEL% == 0 (
::	echo Build configuration succeeded.
::) else (
::	echo Error: Build configuration failed!
::	set /p dummy=Press ENTER...
::	exit /b 1
::)

::ninja -C build
mkdir build && mkdir build\bin
"%MK_LLVM_DIR%/bin/clang-cl" /nologo /EHsc /MD /O2 /Ob2 /DNDEBUG src/mk.cpp /o build\bin\
"%MK_LLVM_DIR%/bin/clang-cl" /nologo /EHsc /MD /O2 /Ob2 /DNDEBUG src/llvm-rc-rc.cpp /o build\bin\

if %ERRORLEVEL% == 0 (
	echo Build succeeded.
) else (
	echo Error: Build failed!
	set /p dummy=Press ENTER...
	exit /b 1
)

:: Copying files

echo.
echo Copying files to "%MK_INSTALL_DIR%"...

xcopy /E /F /Y /R "%~dp0\..\..\build\bin" "%MK_INSTALL_DIR%\bin\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

xcopy    /F /Y /R "%~dp0\refreshenv.cmd" "%MK_INSTALL_DIR%\bin\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

xcopy    /F /Y /R "%~dp0\vsdevcmd_proxy.bat" "%MK_INSTALL_DIR%\bin\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)

xcopy    /F /Y /R "%~dp0\vswhere.exe" "%MK_INSTALL_DIR%\bin\"
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
@exit /b 0

:: GetRegistryValue (KEY, VALUE)
:GetRegistryValue
FOR /F "usebackq tokens=2,* skip=2" %%L IN (
    `reg query %~1 /v %~2`
) DO SET %~1=%%M
exit /b 0

:: CheckPATH (NAME, EXE)
:CheckPATH
echo Checking the presence of %~1...
where /q %~2
if %ERRORLEVEL% == 0 (
	echo %~1 is OK!
) else (
	echo Error: %~1 cannot be found in PATH!
	exit /b 1
)
exit /b 0

:: CreateEnvVariable (NAME, VALUE)
:CreateEnvVariable
echo Creating environment variable %~1...
setx %~1 "%~2:\=/%"
exit /b 0

:: CopyFile (SRC, DEST)
:CopyFile
xcopy /F /Y /R "%~1" "%~2\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)
exit /b 0

:: CopyDirectory (SRC, DEST)
:CopyDirectory
xcopy /E /F /Y /R "%~1" "%~2\"
if %ERRORLEVEL% NEQ 0 (
	exit /b %ERRORLEVEL%
)
exit /b 0

:: Compile (SRC, DEST)
:Compile
clang-cl /nologo /EHsc /MD /O2 /Ob2 /DNDEBUG "%~1" /o %~2\"
exit /b 0


