@echo off

:: call mk_config.bat %1
ninja -C build_%1 -t clean
call mk_make.bat %1
