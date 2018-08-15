@echo off
vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath > vsdevcmd_dir.txt
set /p VSDEVCMD_DIR=< vsdevcmd_dir.txt
call "%VSDEVCMD_DIR%\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
del vsdevcmd_dir.txt
exit /b %ERRORLEVEL%
