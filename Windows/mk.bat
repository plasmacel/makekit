if "%1" == "make" (
	call mk_make.bat %2
) else if "%1" == "build" (
	call mk_build.bat
) else (
	if "%1" == "" (
		echo No command specified.
	) else (
		echo Invalid command: "%1"
	)
)
