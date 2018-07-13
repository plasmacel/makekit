@echo off
cd %~dp0
if exist "build\" (
	echo "Deleting previous build directory..."
	@RD /S /Q "build"
)
call vcvars64.bat
cmake %~dp0 -G "Ninja" -B "build" -DCMAKE_C_COMPILER="C:/Program Files/LLVM/bin/clang-cl.exe" -DCMAKE_CXX_COMPILER="C:/Program Files/LLVM/bin/clang-cl.exe" -DCMAKE_LINKER="C:/Program Files/LLVM/bin/lld-link.exe"
set /p dummy=Press any button:
@echo on