@echo off

:: Set environment variables for x64
call vcvars64.bat

:: Run Ninja
ninja -v -C build

@echo on