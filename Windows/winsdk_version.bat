@echo off

:: Set Windows Kits directory
set WINSDK_DIR=C:\Program Files (x86)\Windows Kits\10\Include

:: Search last directory in lexicographical order
cd %WINSDK_DIR%
setlocal enableDelayedExpansion
for /f %%G in ('dir /b') do set WINSDK_VER=%%~G

:: Print value
echo Detected Windows 10 SDK Version: %WINSDK_VER%

:: Return value
endlocal&set %~1=%WINSDK_VER%

@echo on
