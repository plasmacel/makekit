@echo off

:: Delete build directory if exists
if exist "build_%1\" (
	echo Deleting directory build_%1...
	@RD /S /Q "build_%1"
) else (
	echo Nothing to clean.
)
