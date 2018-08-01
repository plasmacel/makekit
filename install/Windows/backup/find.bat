@echo off

where /F /R "%ProgramFiles(x86)%\Microsoft Visual Studio\2017" %1 > find_temp.txt

if %ERRORLEVEL% == 0 (
	set /p OUTPUT=<find_temp.txt
	echo vcvarsall.bat found at %OUTPUT%
) else (
	set OUTPUT=""
	echo vcvarsall.bat cannot be found!
)

del /F /Q find_temp.txt
