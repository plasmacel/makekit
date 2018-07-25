@echo off

if "%1" == "PATH" (
	PowerShell -NoProfile -ExecutionPolicy Bypass -file "%~dp0\export_path.ps1" "%2"
) else (
	setx "%1" "%2"
)