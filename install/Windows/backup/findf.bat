@echo off
set RDIR="%ProgramFiles(x86)%\Microsoft Visual Studio\2017"
call :FindFile %1 %RDIR%
exit /b %ERRORLEVEL%

:FindFile
where /F /R %2 %1 > find_temp.txt

if %ERRORLEVEL% == 0 (
	set /p %1=<find_temp.txt
	echo File found at %1
) else (
	set %1=
	echo File cannot be found!
)

del /F /Q find_temp.txt
exit /b 0
