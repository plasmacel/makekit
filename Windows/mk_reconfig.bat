@echo off
echo Cleaning %1 configuration...
if exist "build_%1\CMakeCache.txt" ( del "build_%1\CMakeCache.txt" )
call config.bat %1
