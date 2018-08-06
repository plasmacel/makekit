@if not defined _echo echo off

for /f "usebackq delims=" %%i in (`vswhere -nologo -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
	if exist "%%i\Common7\Tools\vsdevcmd.bat" (
		:: Call vsdevcmd.bat but suppress its output
		call "%%i\Common7\Tools\vsdevcmd.bat" %* 1> NUL
		exit /b 0
	)
)

:: Instance or command prompt not found
exit /b 2
