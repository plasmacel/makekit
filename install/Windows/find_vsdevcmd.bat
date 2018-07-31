@echo off
vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath > find_vsdevcmd.txt
set /p FIND_ROOT=< find_vsdevcmd.txt
where /F /R "%FIND_ROOT%" VsDevCmd.bat > find_vsdevcmd.txt
exit /b %ERRORLEVEL%