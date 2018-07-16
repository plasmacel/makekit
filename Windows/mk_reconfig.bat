@echo off
echo Cleaning %1 configuration...
if exist "build_%1\" ( @RD /S /Q "build_%1" )
call config.bat %1