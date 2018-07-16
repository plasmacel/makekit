@echo off

:: Set environment variables for x64
if not "%VSCMD_ARG_TGT_ARCH%" == "x64" (
	if not "%VSCMD_ARG_HOST_ARCH%" == "x64" (
		call vcvars64.bat
	)
)

:: Reconfig if required

set MAKEKIT_CONFIG_REQUIRED=0;

if not exist "build_%1\build.ninja" ( set MAKEKIT_CONFIG_REQUIRED=1 )
if not exist "build_%1\CMakeCache.txt" ( set MAKEKIT_CONFIG_REQUIRED=1 )
if not exist "build_%1\rules.ninja" ( set MAKEKIT_CONFIG_REQUIRED=1 )

if %MAKEKIT_CONFIG_REQUIRED% == 1 (
	call mk_config.bat %1
)

:: Run Ninja
echo Making %1 build...
ninja -v -C build_%1

@echo on
