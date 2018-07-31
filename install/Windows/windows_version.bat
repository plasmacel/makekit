@echo off
:: wmic os get version
set RESULT=0
call :IsWindows10 RESULT
echo %RESULT%
exit /b %ERRORLEVEL%

:: https://stackoverflow.com/a/13212116/2430597

:WindowsVersion
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%VERSION%" == "10.0" echo Windows 10 / Windows Server 2016
if "%VERSION%" == "6.3" echo Windows 8.1 / Windows Server 2012 R2
if "%VERSION%" == "6.2" echo Windows 8 / Windows Server 2012
if "%VERSION%" == "6.1" echo Windows 7 / Windows Server 2008 R2
if "%VERSION%" == "6.0" echo Windows Vista / Windows Server 2008
if "%VERSION%" == "5.2" echo Windows XP Professional x64 Edition / Windows Server 2003
if "%VERSION%" == "5.1" echo Windows XP
if "%VERSION%" == "5.0" echo Windows 2000
if "%VERSION%" == "4.10" echo Windows 98
set %~1=%VERSION%
exit /b 0

:IsWindows10
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%VERSION%" == "10.0" ( set %~1=true ) else ( set %~1=false )
exit /b 0
