@echo off

:: Set environment variables for x64
if not "%VSCMD_ARG_TGT_ARCH%" == "x64" (
	if not "%VSCMD_ARG_HOST_ARCH%" == "x64" (
		call vcvars64.bat
	)
)

:: Run Ninja
ninja -v -C build

@echo on
