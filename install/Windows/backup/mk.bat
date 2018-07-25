@echo off

if "%1" == "clean" (
	call mk_clean.bat %2
) else if "%1" == "config" (
	call mk_config.bat %2
) else if "%1" == "make" (
	call mk_make.bat %2
) else if "%1" == "reconfig" (
	call mk_reconfig.bat %2
) else if "%1" == "refresh" (
	call mk_refresh.bat %2
) else if "%1" == "remake" (
	call mk_remake.bat %2
) else (
	if "%1" == "" (
		echo No command specified.
	) else (
		echo Invalid command: "%1"
	)
)

@echo on
